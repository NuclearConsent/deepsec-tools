const request = require('request-promise');
require('dotenv').config()
const host = 'https://app.deepsecurity.trendmicro.com';


request({
    'method': 'POST',
    'uri': host + '/rest/authentication/login',
    'json': true,
    'body': {
        dsCredentials: {
          userName: process.env.USERNAME,
          password: process.env.PASSWORD,
          tenantName: process.env.TENANT
        }
      },
    'headers': {
        'Content-Type': 'application/json'
    }
}).then(console.log, console.log);