const request = require('request-promise');
const host = 'https://app.deepsecurity.trendmicro.com';


request({
    "method": "POST",
    "uri": host + '/rest/authentication/login',
    "json": true,
    "headers": {
        "User-Agent": ""
    }
}).then(console.log, console.log);