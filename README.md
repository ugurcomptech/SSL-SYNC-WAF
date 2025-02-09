# SSL Sertifika Yenileme ve WAF Senkronizasyonu

Bu betik, Cloudflare DNS doğrulaması kullanarak SSL sertifikasını yeniler, WAF sunucusuna senkronize eder ve Apache sunucusunu günceller.

## 🚀 Özellikler
- **Cloudflare DNS doğrulaması ile SSL sertifika yenileme**
- **Apache (httpd) sunucusunu durdurma ve başlatma**
- **WAF sunucusuna SSH üzerinden bağlanarak BT Panel'i durdurma ve başlatma**
- **Yeni sertifikaları WAF sunucusuna senkronize etme**
- **Port (80/443) durum kontrolü**
- **Otomatik hata yönetimi ve loglama**

## 📜 Kullanım

### 1️⃣ Değişkenleri Güncelleyin
Aşağıdaki değişkenleri ihtiyacınıza göre güncelleyin:

```bash
DOMAIN="example.com"
EMAIL="admin@example.com"
WAF_SERVER="your.waf.server.ip"
WAF_USER="your_waf_user"
CLOUDFLARE_CREDENTIALS="/root/.cloudflare.ini"
SSH_KEY="/root/.ssh/id_rsa"
```

### 2️⃣ Betiği Çalıştırın

Betiği çalıştırmadan önce **Cloudflare API bilgilerini** `.cloudflare.ini` dosyanıza eklediğinizden emin olun.

```bash
chmod +x auto-ssl.sh
./auto-ssl.sh
```

### 3️⃣ Başarıyla Çalıştırıldıktan Sonra
✅ Apache ve WAF üzerindeki SSL sertifikaları güncellenmiş olur.

## 🛠 Gereksinimler
- `certbot` (Cloudflare DNS doğrulaması için)
- `rsync` (Dosya senkronizasyonu için)
- `ssh` (WAF sunucusuna erişim için)
- `openssl` (Sertifika kontrolü için)

## 🔥 Önemli Notlar
- **SSH bağlantısı için parola yerine SSH anahtarı kullanılmalıdır.**
- **Cloudflare API bilgileri güvenli bir şekilde saklanmalıdır.**
- **Apache ve WAF sunucularının uygun izinlere sahip olduğundan emin olun.**
-- **Bu sistem, aapanel ve aawaf'ın yapısına göre hazırlanmıştır. Kendi kullanmış olduğunuz web panel ve WAF'a göre değiştirebilirsiniz.**
---
Bu betik, **otomatik SSL yenileme ve güvenli WAF entegrasyonu** sağlamak için tasarlanmıştır. 🚀

