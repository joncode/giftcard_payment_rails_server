module PaymentGatewayMobile



#curl -H "Content-Type: text/xml"  -d '<?xml version="1.0" encoding="utf-8"?><mobileDeviceLoginRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><merchantAuthentication><name>Dbtestapp1</name><password>10Brown15</password><mobileDeviceId>42741F4C-3C79-4C57-BF12-0591BFBB7956</mobileDeviceId></merchantAuthentication></mobileDeviceLoginRequest>' https://apitest.authorize.net/xml/v1/request.api


#<?xml version="1.0" encoding="utf-8"?><mobileDeviceLoginResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><sessionToken>3oZPrCdJ0$Rooo8pXXQX41NXMXLo$n7n7H7iSBs8vR$P2UP4uiJP4dtc7R$0dBgSwnbYVYthLBRcJVjVYicZ7kvjSOoXE316oR$sx0$aCA3mCOxXE0oPd1nW0IybqnRhi9uNrWfP8mJeEaJiZIbdtgAA</sessionToken><merchantContact><merchantName>Craig McAulay</merchantName><merchantAddress>1 Main Street</merchantAddress><merchantCity>Bellevue</merchantCity><merchantState>WA</merchantState><merchantZip>98004</merchantZip><merchantPhone>425-555-1212</merchantPhone></merchantContact><userPermissions><permission><permissionName>Submit_Charge</permissionName></permission><permission><permissionName>Submit_Refund</permissionName></permission><permission><permissionName>Submit_Update</permissionName></permission><permission><permissionName>API_Merchant_BasicReporting</permissionName></permission><permission><permissionName>Mobile_Admin</permissionName></permission></userPermissions><merchantAccount><marketType>0</marketType><deviceType>7</deviceType></merchantAccount></mobileDeviceLoginResponse>






end