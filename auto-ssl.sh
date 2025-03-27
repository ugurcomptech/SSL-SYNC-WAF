#!/bin/bash

# 🌍 Değişkenler
DOMAIN="r"
EMAIL=""
SOURCE_CERT_PATH=""
DEST_CERT_PATH=""
WAF_SERVER=""
WAF_USER=""
WAF_PASSWORD=""

# Cloudflare API bilgileri (Gizli dosyadan okunmalı)
CLOUDFLARE_CREDENTIALS="/root/.cloudflare.ini"

# SSH bağlantısı için parola yerine SSH anahtarlarını kullanın!
SSH_KEY="/root/.ssh/id_rsa"

# Apache'yi durdur
echo "Apache (httpd) durduruluyor..."
systemctl stop httpd || { echo "❌ Apache durdurulamadı!" ; exit 1; }

# WAF sunucusunda BT Panel'i durdur
echo "WAF sunucusunda BT Panel durduruluyor..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $WAF_USER@$WAF_SERVER "sudo btw stop" || { echo "❌ WAF sunucusunda BT Panel durdurulamadı!" ; exit 1; }

#  Eski sertifikaları yedekleyip temizle
echo "Eski SSL sertifikaları yedekleniyor ve temizleniyor..."
mkdir -p $SOURCE_CERT_PATH/backup
mv -f $SOURCE_CERT_PATH/*.pem $SOURCE_CERT_PATH/backup/ || echo "Eski sertifikalar bulunamadı, devam ediliyor..."

#  Yeni SSL sertifikası oluştur (Cloudflare DNS doğrulaması ile)
echo "Yeni SSL sertifikası oluşturuluyor (Cloudflare)..."
certbot certonly --dns-cloudflare --dns-cloudflare-credentials $CLOUDFLARE_CREDENTIALS --email $EMAIL -d $DOMAIN --agree-tos --non-interactive  --force-renewal || { echo "❌ Yeni SSL sertifikası oluşturulamadı!" ; exit 1; }

#  Yeni sertifikaları belirlenen dizine taşı
echo "Yeni SSL sertifikaları belirtilen dizine taşınıyor..."
cp -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem $SOURCE_CERT_PATH/fullchain.pem || { echo "❌ fullchain.pem kopyalanamadı!" ; exit 1; }
cp -f /etc/letsencrypt/live/$DOMAIN/privkey.pem $SOURCE_CERT_PATH/privkey.pem || { echo "❌ privkey.pem kopyalanamadı!" ; exit 1; }

# SSL dosyalarını WAF sunucusuna aktar
echo "SSL dosyaları WAF sunucusuna aktarılıyor..."
rsync -avz --checksum --progress -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" $SOURCE_CERT_PATH/fullchain.pem $WAF_USER@$WAF_SERVER:$DEST_CERT_PATH/fullchain.pem || { echo "❌ Rsync başarısız!" ; exit 1; }
rsync -avz --checksum --progress -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" $SOURCE_CERT_PATH/privkey.pem $WAF_USER@$WAF_SERVER:$DEST_CERT_PATH/privkey.pem || { echo "❌ Rsync başarısız!" ; exit 1; }

#  WAF sunucusunda BT Panel'i başlat
echo "WAF sunucusunda BT Panel başlatılıyor..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $WAF_USER@$WAF_SERVER "sudo btw start" || { echo "❌ BT Panel başlatılamadı!" ; exit 1; }

#  WAF sunucusunda 80/443 portlarını kontrol et
echo "80 ve 443 portlarının durumunu kontrol ediliyor..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $WAF_USER@$WAF_SERVER "sudo netstat -tulnp | grep -E ':80|:443'" || { echo "❌ Port kontrolü başarısız!" ; exit 1; }

#  Apache'yi tekrar başlat
echo "Apache (httpd) yeniden başlatılıyor..."
systemctl start httpd || { echo "❌ Apache başlatılamadı!" ; exit 1; }

#  SSL sertifika geçerliliğini kontrol et
openssl x509 -in $SOURCE_CERT_PATH/fullchain.pem -noout -dates || { echo "❌ SSL sertifikası kontrol edilemedi!" ; exit 1; }

echo "✅ Yeni SSL Sertifikası başarıyla oluşturuldu, belirtilen dizine aktarıldı, WAF'a yüklendi ve servisler yeniden başlatıldı."
