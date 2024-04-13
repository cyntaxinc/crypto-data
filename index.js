const express = require('express');
const fs = require('fs');
const axios = require('axios');
const cors = require('cors');
var cron = require('node-cron');
require("dotenv").config();

const PORT = process.env.PORT || 5000;
const APIKEY = process.env.API_KEY;
const app = express();

var corsOptions = {
  origin: "*"
};

// enable cross-origin resource sharing
app.use(cors(corsOptions));
// parse requests of content-type - application/json
app.use(express.json());
// parse requests of content-type - application/x-www-form-urlencoded
app.use(express.urlencoded({ extended: true }));

// simple route
app.get("/", (req, res) => {
  res.json({ error : "Access Denied" });
});

app.get('/marquee', (req, res) => {
  fs.readFile("marquee.json", function(err, data) {
    if (err) throw err;
    const info = JSON.parse(data);

    const keyMapping = {
        active_cryptocurrencies: 'active_cryptocurrencies',
        total_cryptocurrencies: 'total_cryptocurrencies',
        active_exchanges: 'active_exchanges',
        total_exchanges: 'total_exchanges',
        eth_dominance: 'eth_dominance',
        btc_dominance: 'btc_dominance',
        last_updated: 'last_updated'
    };

    const new_data = {};

    for (const originalKey in keyMapping) {
        if (info.data.hasOwnProperty(originalKey)) {
            new_data[keyMapping[originalKey]] = info.data[originalKey];
        }
    }

    res.json(new_data);
  });
});

cron.schedule('*/30 * * * *', () => {
  console.log("refresh");
  let response = null;

  new Promise(async (resolve, reject) => {
    try {
      response = await axios.get('https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest', {
        headers: { 
          'X-CMC_PRO_API_KEY': APIKEY, // insert your API Key
        },
      });
    } catch(ex) {
      response = null;
      // error
      console.log(ex);
      reject(ex);
    }
    if (response) {
      // success
      fs.writeFile('marquee.json', JSON.stringify(response.data), (err) => {
          if(err) throw err;
          console.log('Data written to file');
      });
      const json = response.data;
      resolve(json);
    }
  });
});


app.listen(PORT, () => console.log(`Backend server started on port ${PORT}`));
