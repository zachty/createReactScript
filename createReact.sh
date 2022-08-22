#!/usr/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied, please give the app a name and optoinally a database:\n\t$0 [app] [database]"
fi

if [ $# -gt 0 ]
then
    #create app then wait for it to finish
    npx create-react-app $1
    wait
    #move into public folder and remove fluff
    cd $1/public
    rm *.png favicon.ico manifest.json robots.txt 
    #move into src folder and remove fluff
    cd ../src
    rm logo.svg reportWebVitals.js setupTests.js App.test.js

    #remove lines from ./src/index
    sed -i -E '/\/\/|React.StrictMode|reportWebVitals/d' ./index.js

    #remove first line and fluff in app.js
    sed -i '1d;7,20d' ./App.js
    
    #move back into working directory
    cd ..

    #create database for dev use
    if [ $# -gt 1 ]
    then
        #make database and files/folders
        createdb $2
        mkdir server && cd $_
        mkdir routes
        mkdir db

        #setup db
        cd db
        touch seed.js
        #input into /server/db/db.js
        echo "const Sequelize = require('sequelize');

const db = new Sequelize(
  process.env.DATABASE_URL || 'postgres://localhost/$2',
  {
    logging: false,
  }
);

module.exports = db;" >> db.js

        #input into /server/db/index.js
        echo "const db = require('./db');
const seed = require('./seed');

// create any associations between different tables here

module.exports = {
  db,
  seed,
};" >> index.js

        #setup app and index
        cd ..
        #input into server/app.js
        echo "const express = require('express');
const morgan = require('morgan');
const path = require('path');
const app = express();

if (process.env.NODE_ENV !== 'testing') app.use(morgan('dev'));

app.use(express.json());

app.use('/api/', require('./routes/'));
app.use('/api/*', (req, res) => {
  res.status(404).send({ message: 'Not Found' });
});

app.use(express.static(path.join(__dirname, '..', 'public')));

app.use('/', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public/index.html'));
});

app.use((err, req, res, next) => {
  res.status(err.status || 500).send({ message: err.message });
});

module.exports = app;" >> app.js

        #input into server/index.js
        echo "const app = require('./app');
const port = process.env.PORT || 3000;
const db = require('./db');

if (process.env.SEED) {
    console.log('CREATE A SEED AND USE IT HERE')
  /*db.seed()
    .then((users) => {
      console.log(`${Object.keys(users).length} users seeded!`);
    })
    .catch((ex) => {
      throw Error(ex);
    });*/
}

app.listen(port, () => console.log(`listening on port ${port}`));" >> index.js

        #move back into working directory and add start-dev-seed script
        cd ..
        sed -i '18s/$/,/' package.json
        sed -i '18a\ \ \ \ "start-dev-seed": "SEED=true npm run start"' package.json

    fi

    code .
    npm run start
fi
