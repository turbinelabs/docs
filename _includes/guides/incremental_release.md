### Incremental release with Simple Release Workflow

#### Configuration of Simple Release Workflow

Now we're ready to do an incremental release from blue to green. Right now the
default rules for `/api` send all traffic to blue. Let’s introduce a small
percentage of green traffic to customers.

First, we must enable the Simple Release Workflow. Navigate to
[app.turbinelabs.io](https://app.turbinelabs.io), log in and select the zone
you’re working with (testbed by default). Click the "Route Groups" tab below
the top-line charts, then click the pencil icon in the "all-in-one-server" row.
This will take you to the Route Group editor. Scroll down to "Default
Behavior"

<img src="/assets/rge_unmanaged.png" />

Click "Manage" to enable Simple Release Management. Choose the label which
will vary with different versions of your service (in this case "version"), and
the current value (in this case "blue").

<img src="/assets/rge_manage_modal.png" width="50%" />

Click "Enable Simple Release Workflow". Then click "Save Changes" in the top
right of the window. Finally, click "More..." and then "View Charts" to go back
to the chart view.

#### Incremental release

The "all-in-one-server" row should be now marked "RELEASE READY". Click anywhere
in the row to expand it, then click "Start Release".

<img src="/assets/release_ready.png" />

Let's send 25% of traffic to our new green version by
moving the slider and clicking "Start Release". The Route Group should now
be marked "RELEASING".

<img src="/assets/releasing_green.png" />

The all in one client should now show a mix of blue and green. You can
increment the green percentage as you like. When you get to 100%, the release
is complete.

<img src="/assets/spray_green_blue.png" width="50%" height="50%"/>

Congratulations! You've safely and incrementally released a new version of your
production software. Both blue and green versions are still running; if a
problem were found with green, a rollback to blue would be just as easy.
