## Configure routes

Now we have a Proxy running and exposed to the Internet, along with Services and
instances configured in the Turbine Labs API. Next we map requests to
Services. Log in to https://app.turbinelabs.io.

First we'll create a Route Group and Route to send traffic to the all-in-one
client.

1. Make sure you have the 'testbed' zone selected in the top left portion of the
screen.
2. Click the "+ MORE" menu in the top right portion of the screen, and then
select "Create Route Group".
3. Select "all-in-one-client" from the service drop down
4. Name your release group "all-in-one-client"
5. Click "CREATE"
6. Click the "HOUSTON" logo to return to the main screen
7. Click the "More" menu, then select "Create Route".
8. Select your Domain in the domain drop down
9. Enter "/" in the path field
10. Click the Route Group dropdown and select "all-in-one-client"
11. Click "CREATE"
12. Click the "HOUSTON" logo to return to the main screen

Now we'll repeat these steps to create a Route Group and Route to send anything
going to /api to the all-in-one server

1. Make sure you have the 'testbed' zone selected in the top left portion of the
screen.
2. Click the "+ MORE" menu in the top right portion of the screen, and then
select "Create Route Group".
3. Select "all-in-one-server" from the service drop down
4. Name your release group "all-in-one-server"
5. Click "CREATE"
6. Click the "HOUSTON" logo to return to the main screen
7. Click the "More" menu, then select "Create Route".
8. Select your Domain in the domain drop down
9. Enter "/" in the path field
10. Click the Route Group dropdown and select "all-in-one-server"
11. Click "CREATE"
12. Click the "HOUSTON" logo to return to the main screen
