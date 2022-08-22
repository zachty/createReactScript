# Create React Script

Add this as an executable to /usr/bin then you can call createReact directoryName [databaseName] to run npx create-react-app, delete a bunch of extra lines and files, then open in vscode and start the server. Optionally can be given a database name to also create a database in postgres and set up the app with a server folder and some biolerplate files including an empty seed file.
To make this executable on linux get the code as a .sh file, run the commands:
```chmod +x createReact.sh```
```sudo cp createReact.sh /usr/bin/createReact```
