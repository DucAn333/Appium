# Appium + TypeScript (Android)

WebdriverIO + Mocha, Appium 3 và UiAutomator2. Mặc định test mở ứng dụng Settings trên Android.

## Chuẩn bị Windows

1. Cài JDK 17 trở lên, đặt `JAVA_HOME` tới thư mục JDK và thêm `%JAVA_HOME%\bin` vào PATH.
2. Cài Android Studio. Trong SDK Manager cài Android SDK Platform, Platform-Tools, Emulator và Command-line Tools.
3. Đặt `ANDROID_HOME` tới SDK (thường là `%LOCALAPPDATA%\Android\Sdk`). Thêm `%ANDROID_HOME%\platform-tools` và `%ANDROID_HOME%\emulator` vào PATH.
4. Mở terminal mới. Khởi động emulator trong Device Manager, hoặc kết nối điện thoại đã bật USB debugging và chấp nhận quyền debug.

```powershell
java -version
adb devices
```

Thiết bị cần có trạng thái `device`.

## Cài đặt và chạy

```powershell
npm install
npm run doctor
Copy-Item .env.example .env
npm run typecheck
npm test
```

WebdriverIO tự bật/tắt Appium tại `127.0.0.1:4723` khi chạy test. Không cần chạy `npm run appium` cùng lúc; lệnh này dành cho việc khởi động server riêng khi dùng Inspector.

UiAutomator2 đã được khai báo trong devDependencies và được Appium tự nhận diện. Xem driver bằng `npx appium driver list --installed`.

## Mở Android từ dự án này (Windows)

Chạy tại `C:\Users\Admin\OneDrive\Desktop\appiumTypeScript`:

```powershell
npm run android:check
npm run android
```

`npm run android` hiển thị cửa sổ. Để chạy ẩn:

```powershell
npm run android:headless
```

Script `scripts/start-emulator.ps1` tạo máy ảo riêng `appium_ts_api35` trong `.android-avd/` của dự án này. SDK lấy từ `ANDROID_HOME` (tiến trình hiện tại hoặc User environment của Windows); SDK có thể dùng chung, không gọi script hay dùng AVD của dự án khác. Cần cài sẵn system image `system-images;android-35;google_apis;x86_64` và Command-line Tools trong SDK.

Emulator dùng cổng 5556, vì vậy đặt `DEVICE_UDID=emulator-5556` trong `.env`. Đợi Android vào màn hình chính, rồi mở terminal thứ hai và chạy `npm test`. Tắt cửa sổ emulator hoặc nhấn Ctrl+C trong terminal khởi động trước khi đổi chế độ. Các lệnh này dành cho Windows; Linux CI cần khởi động emulator bằng công cụ của runner.

## Cấu hình ứng dụng

Đặt `APP_PATH` trong `.env` tới file APK, ví dụ `APP_PATH=./apps/app.apk`. Hoặc đặt cả `APP_PACKAGE` và `APP_ACTIVITY` để mở ứng dụng đã cài. Chọn thiết bị bằng `DEVICE_UDID` từ `adb devices`, đặc biệt khi có nhiều thiết bị.

Test nằm trong `test/specs/`; cấu hình trong `wdio.conf.ts`. Smoke test chỉ xác nhận Appium mở được phiên và đọc được giao diện; hãy thêm assertion nghiệp vụ phù hợp với ứng dụng.

iOS cần máy macOS với Xcode và driver XCUITest; cấu hình này dành cho Android.

## Appium Inspector: mở Android Settings

Khởi động emulator bằng `npm run android`, sau đó mở terminal thứ hai và chạy `npm run appium`. Trong Inspector đặt Remote Host `127.0.0.1`, Remote Port `4723`, Remote Path `/`, SSL tắt.

Dán JSON sau vào **JSON Representation**, rồi nhấn **Start Session** để mở ứng dụng Settings có sẵn trên emulator:

```json
{
  "platformName": "Android",
  "appium:automationName": "UiAutomator2",
  "appium:deviceName": "Android",
  "appium:udid": "emulator-5556",
  "appium:appPackage": "com.android.settings",
  "appium:appActivity": ".Settings",
  "appium:noReset": true
}
```

Nếu dùng thiết bị khác, đổi `appium:udid` theo kết quả `adb devices`. Kết thúc phiên Inspector và dừng server chạy riêng trước khi chạy `npm test`.

## Trạng thái kiểm tra khi thiết lập

- TypeScript và việc nạp cấu hình đã kiểm tra thành công.
- Appium nhận diện UiAutomator2 8.7.0.
- Doctor báo thiếu JAVA_HOME, ANDROID_HOME và Android SDK tools; chưa chạy test trên thiết bị.
- npm audit còn báo 19 lỗ hổng trong các dependency đóng gói kèm driver. `npm audit fix` chưa xử lý được chúng; cần bản cập nhật từ driver. Server được cấu hình chỉ lắng nghe localhost.

Tài liệu: [WebdriverIO Mobile](https://webdriver.io/docs/platforms/mobile), [Appium Service](https://webdriver.io/docs/appium-service).
