 var request = require('request');
        request({
            url: "eu-ext.linnworks.net",
            json: true,
            headers: {
                "content-type": "application/json",
                "POST": "https://eu-ext.linnworks.net//api/Inventory/GetInventoryItemExtendedProperties HTTP/1.1"
  //              "Connection": "keep-alive"
  //              "Accept": "application/json, text/javascript, */*; q=0.01"
  //              "Origin": "https://www.linnworks.net"
    //            "Accept-Language": "en"
    //            "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"
      //          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
  //              "Referer": "https://www.linnworks.net/"
  //              "Accept-Encoding": "gzip, deflate"
                "Authorization": "e963878d-e52a-40fc-93f8-8bbacdca66b9"
            },
            body: JSON.stringify(requestData)
        }, function(error, response, body) {
            console.log(response);
        });
