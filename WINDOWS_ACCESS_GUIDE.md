# دليل الوصول إلى Cursor VIP من Windows

## 🖥️ **الوصول من جهاز Windows إلى الخادم**

### **المعلومات المطلوبة:**
- **عنوان IP الخادم:** `172.31.92.48` (عنوان داخلي)
- **المستخدم:** `admin`
- **الميناء:** `22` (افتراضي SSH)

### **الطرق المختلفة للوصول:**

## 1. **استخدام PuTTY (الأسهل)**

### **خطوات التثبيت:**
1. حمل PuTTY من: https://www.putty.org/
2. شغل PuTTY
3. أدخل المعلومات التالية:
   - **Host Name:** `172.31.92.48`
   - **Port:** `22`
   - **Connection Type:** SSH
4. اضغط "Open"

### **بعد الاتصال:**
```bash
# انتقل إلى مجلد التطبيق
cd /home/admin/projects/cursor-vip

# شغل التطبيق تفاعلياً
./access-cursor-vip.sh interactive
```

## 2. **استخدام Windows Terminal + SSH**

### **في Windows Terminal أو PowerShell:**
```bash
# الاتصال بالخادم
ssh admin@172.31.92.48

# بعد الاتصال، انتقل إلى مجلد التطبيق
cd /home/admin/projects/cursor-vip

# شغل التطبيق تفاعلياً
./access-cursor-vip.sh interactive
```

## 3. **استخدام VS Code مع Remote SSH**

### **خطوات التثبيت:**
1. حمل VS Code من: https://code.visualstudio.com/
2. ثبت إضافة "Remote - SSH"
3. اضغط `Ctrl+Shift+P` واكتب "Remote-SSH: Connect to Host"
4. أدخل: `admin@172.31.92.48`
5. افتح Terminal في VS Code وشغل:
   ```bash
   cd /home/admin/projects/cursor-vip
   ./access-cursor-vip.sh interactive
   ```

## 4. **استخدام MobaXterm (للأغراض المتقدمة)**

### **خطوات التثبيت:**
1. حمل MobaXterm من: https://mobaxterm.mobatek.net/
2. شغل MobaXterm
3. اضغط "Session" → "SSH"
4. أدخل المعلومات:
   - **Remote host:** `172.31.92.48`
   - **Username:** `admin`
   - **Port:** `22`
5. اضغط "OK"

## 🎮 **أوامر التحكم في التطبيق**

### **الأوامر المتاحة:**
```bash
# شغل التطبيق تفاعلياً
./access-cursor-vip.sh interactive

# عرض السجلات
./access-cursor-vip.sh logs

# عرض حالة الخدمة
./access-cursor-vip.sh status

# إعادة تشغيل الخدمة
./access-cursor-vip.sh restart

# إيقاف الخدمة
./access-cursor-vip.sh stop

# تشغيل الخدمة
./access-cursor-vip.sh start
```

### **أوامر التطبيق التفاعلية:**
- **`szh`** - التبديل إلى اللغة الصينية
- **`sen`** - التبديل إلى اللغة الإنجليزية
- **`sm1`** - وضع 1
- **`sm2`** - وضع 2
- **`sm3`** - وضع 3
- **`sm4`** - وضع 4
- **`buy`** - رابط الدفع
- **`q3d`** - عرض الأيام المتبقية

## 🔧 **استكشاف الأخطاء**

### **مشاكل شائعة:**

#### **1. لا يمكن الاتصال بالخادم:**
```bash
# تحقق من الاتصال
ping 172.31.92.48

# تحقق من SSH
ssh -v admin@172.31.92.48
```

#### **2. التطبيق لا يعمل:**
```bash
# تحقق من حالة الخدمة
sudo systemctl status cursor-vip

# عرض السجلات
sudo journalctl -u cursor-vip -f
```

#### **3. مشاكل الصلاحيات:**
```bash
# إصلاح الصلاحيات
sudo chown -R cursor-vip:cursor-vip /opt/cursor-vip
sudo chmod +x /opt/cursor-vip/cursor-vip
```

## 📱 **الوصول من الهاتف المحمول**

### **تطبيقات SSH للهاتف:**
- **Android:** Termux, JuiceSSH
- **iOS:** Termius, Prompt 3

### **خطوات الاتصال:**
1. افتح تطبيق SSH
2. أدخل المعلومات:
   - **Host:** `172.31.92.48`
   - **User:** `admin`
   - **Port:** `22`
3. اتصل وانتقل إلى: `cd /home/admin/projects/cursor-vip`
4. شغل: `./access-cursor-vip.sh interactive`

## 🌐 **الوصول عبر الإنترنت (اختياري)**

إذا كنت تريد الوصول من خارج الشبكة المحلية:

### **1. إعداد Port Forwarding:**
```bash
# في الموجه (Router)
# اضبط Port Forwarding:
# External Port: 2222
# Internal IP: 172.31.92.48
# Internal Port: 22
```

### **2. استخدام عنوان IP العام:**
```bash
# احصل على عنوان IP العام
curl -s ifconfig.me

# استخدم العنوان العام للاتصال
ssh admin@YOUR_PUBLIC_IP -p 2222
```

## 🔒 **الأمان**

### **نصائح أمنية:**
1. **استخدم كلمات مرور قوية**
2. **فعّل SSH Key Authentication**
3. **غيّر المنفذ الافتراضي**
4. **استخدم VPN للاتصال الآمن**

### **إعداد SSH Key:**
```bash
# على Windows، أنشئ SSH Key
ssh-keygen -t rsa -b 4096

# انسخ المفتاح العام إلى الخادم
ssh-copy-id admin@172.31.92.48
```

## 📞 **الدعم**

إذا واجهت أي مشاكل:
1. تحقق من السجلات: `./access-cursor-vip.sh logs`
2. تحقق من حالة الخدمة: `./access-cursor-vip.sh status`
3. أعد تشغيل الخدمة: `./access-cursor-vip.sh restart`

---

**ملاحظة:** التطبيق يعمل الآن كخدمة systemd على الخادم ويمكنك الوصول إليه من أي مكان عبر SSH! 🚀
