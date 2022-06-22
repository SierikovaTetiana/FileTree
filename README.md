# 🌳 FileTree App
 File tree presenting Google Sheet. Swift 5. Xcode 13.3. iOS 15.
###### LAYOUTS CREATED IN CODE (UIKIT) 
###### VIEWCONTROLLERS STACK WITH UINAVIGATIONCONTROLLER

## 📷 Screenshots
![MockUpFileTree](https://user-images.githubusercontent.com/75028505/174965469-7130981c-2f12-4a66-879b-b0850e8fab30.jpg)
<img src="https://user-images.githubusercontent.com/75028505/174970981-a74f9ad4-edd0-4f54-ba7c-a0c24b896a78.mp4" width=30% height=30%>

## 🔖 Features: 

- The app is composed of a stack of screens, each displaying contents of a particular folder within a file tree.
- Screen can be Switched to change the layout from grid to table and vice-versa
- Tap on a folder item reveals its contents in a new screen
- User is able to return to parent folders and walk the hierarchy freely 
- Each screen must contain: 
  - Current folder’s title
  - Each list element contains the file name and file thumbnail (“folder” of “file” icon)
- User can sign-in Google account to be able to edit sheet or read private sheets
- User is able to enter his sheetID or defullt sheet will be presented
- Data source and data format: 
  - Google spreadsheet is used as a “server”. The table’s contents imitate a list of files and directories of cloud storage.
- User can add new entries in the application, and they are written to the spreadsheet.
- User can delete entries in the application using long tap, and they are deleted from the spreadsheet.
- Data model is fetched and processed on a separate thread or dispatch_queue.

## 💻 Technologies:
- The Google Sheets API (API key, OAuth 2.0)
- Google Sign-In
