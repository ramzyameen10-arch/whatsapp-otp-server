نحتاج لسيرفر بذاكرة 1 جيجا واكثر

ربط الاي بي بالدومين داخل كلاودفلير
نحتاج دومين وربطه بالسيرفر وتثبيت شهادة اس اس ال
لان موقع سوبابيز لا يرسل الويب هوك الى روابط http
ويرسل فقط الى روابط https

فتح البورت 
443
80
22


تعطيل 
IPv6 networking is disabling

تثبيت السكربت عن طريق نسخة ولصقة بالترمينال


او من خلال  لصق الرابط بالترمينال

bash <(curl -sSL https://raw.githubusercontent.com/ramzyameen10-arch/whatsapp-otp-server/refs/heads/main/install.sh)



ادخال الدومين

اداخل الايميل

DOMAIN: otp.ramzyameen.xyz
EMAIL : ramzyameen@yahoo.com

ثم انتر
سوف يظهر لك رابطين
رابط الويب هوك
ورابط باركود الواتس


لعمل ذاكرة وهمية لتجنب ايقاف السيرفر عن العمل 2 جيجا

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

للتاكد من عمل الذاكرة الوهمية
free -h


في حالة رغبتك باعدة تشغيل النظام استخدم
sudo pm2 restart 0

لمعرفة حالة النظام
sudo pm2 status

 لايقاف الخدمة و لفرمتت المتصفح 
sudo pm2 stop all
sudo pkill -f chromium


لبدء الخدمة
sudo pm2 start whatsapp-otp


لمعرفة سجل الاحداث
sudo pm2 logs whatsapp-otp
 او لمعرفة 50 سطر فقط
sudo pm2 logs whatsapp-otp --lines 50

حافظ الى الواتساب الخاص بارسال الرسائل بجوالك ان لا يدخل في وضع الخمول
