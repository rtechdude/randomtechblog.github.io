---
layout: post
title:  "Extract Teams Channel Messages"
date:   2022-07-22 05:22:20 -0600
categories: cool stuff
---
Microsoft Teams is a great tool for storing data. It provides a secure and collaborative environment for storing and sharing data, as well as managing conversations.

That being said its not always the best tool to store certain data as I recently had a colleague using a Teams channel as a "sticky note" for passwords.

He decided he needed to save all those passwords into a passowrd vault and delete that channel (good idea).
But that would be easier said than done as he had quite a few pasword stored there.

MS graph to the rescue!!!

With MS graph API we can securely access Teams data and then move that data.

First, I had to create a registered app in Azure (instructions can be found here <https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app> ).

Make sure these API permissions are added to the app.

[![Teams](/assets/images/teams1.png)](/assets/images/teams1.png)

And



Grab the newly registered apps Client ID, Redirect URI and secret (previous post will show where to find these).



Now to construct the URL needed to get your authorization code.

This consist of base URL followed by your tenant ID, client ID, redirect uri and then scope.

`https://login.microsoftonline.com/<Tenant ID>/oauth2/v2.0/authorize?client_id=<Client ID>response_type=code&redirect_uri=https://localhost&response_mode=query&scope=offline_access%20ChannelMessage.Read.All&state=12345`



So to break down the URL below:

`https://login.microsoftonline.com/xxxxxx-5555-3333-2222-7a7a7a7a7a7a/oauth2/v2.0/authorize?client_id=999999-1111-1111-cccc-7z4a74a&response_type=code&redirect_uri=https://localhost&response_mode=query&scope=offline_access%20ChannelMessage.Read.All&state=12345`

`Tenant ID is: xxxxxx-5555-3333-2222-7a7a7a7a7a7a`

`Client ID is: 999999-1111-1111-cccc-7z4a74a`

`Redirect URI is: https://localhost`

`Scope is: offline_access%20ChannelMessage.Read.All`


Once you get your URL formatted, copy it in a web browser and when prompted (if not already) login to your O365 account.
You will get redirected to an error page but the URL in the address bar has changed.



Extract the code from the new URL:
New URL will look similar to `https://localhost/?code=alalalzalclvla12a5a12a4a2&state=12345&session_state=asasa-dasa-asas-dddd-dddddasd#`

The authorization code will be between `https://localhost/?code=` and `&state=12345&session_state=asasa-dasa-asas-dddd-dddddasd”`

So in the case of the example above, the code will be “alalalzalclvla12a5a12a4a2”

Now that we have our auth code we can script some stizuff (stuff).



Set you client ID, secret, domain name and auth code

{% highlight bash %}
$clientid='999999-1111-1111-cccc-7z4a74a'

$clientsecret='m.12212121as1a2s1a2s1a2s12'


$ApplicationID=$clientid

$TenatDomainName="supdude.com"

$AccessSecret=$clientsecret

$tenid='xxxxxx-5555-3333-2222-7a7a7a7a7a7a'

$code='alalalzalclvla12a5a12a4a2'


$ReqTokenBody= @{

Grant_Type ="authorization_code"

client_Id =$clientID

code =$code

redirect_uri ="https://bl"

client_secret =$clientsecret

}
{% endhighlight %}

Use that to request a token

{% highlight bash %}
$Tokenresult=Invoke-RestMethod-Uri"https://login.microsoftonline.com/$tenid/oauth2/v2.0/token"-MethodPOST-Body$ReqTokenBody

$token=$Tokenresult.access_token
{% endhighlight %}

Add the token as to your headers

{% highlight bash %}
$headers=New-Object"System.Collections.Generic.Dictionary[[String],[String]]"

$headers.Add('Authorization','Bearer '+$token)
{% endhighlight %}

Build URI (teams ID and channel ID can be retrieve from the Teams admin center)

{% highlight bash %}
$teamsid='xxxxxxxx-xxxx-xxxx-aaaa-asasa'

$channelid='ad"12a1da2da2d1ad1@thread.tacx'

$url="https://graph.microsoft.com/v1.0/teams/$teamsid/channels/$channelid/messages"
{% endhighlight %}

Loop through all messages and add to variable

{% highlight bash %}
$messages= @()

do {

$getinfo=Invoke-RestMethod-Headers$headers-Uri$url

$messages+=$getinfo.value


$url=$getinfo.'@odata.nextLink'

}

while($getinfo-like'*@odata.nextLink*')
{% endhighlight %}

Now you should have all messages in the $message variable.


I then exported to csv for

{% highlight bash %}
$messages|Export-Csv c:\data\bad ideas\stuff.csv-NoTypeInformation
{% endhighlight %}



Thanks for reading!


