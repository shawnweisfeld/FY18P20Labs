# Become a Graph Explorer

This lab will walk you through setting up your own local copy of the [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer). 

## Prerequisites

- **Git**: Any Git client will work. [GitHub for Windows](https://github-windows.s3.amazonaws.com/GitHubSetup.exe) or [Git for Windows](https://git-for-windows.github.io/) are both excellent choices.

- **Node.js**: Download and install v8.5.0 from the [Node.js website](https://nodejs.org/en/). 

- **MSA**: You'll need a personal Microsoft Account to your register your app (the portal doesn't support AD accounts). I will assume you have one of these. ;)

## Cloning Graph Explorer

From a Command Prompt:

1. Create a new directory at the root of C:\ to hold our clone of the repository:

    ```cmd
    MKDIR c:\mw-labs\
    ```

1. Switch to our new directory:

    ```cmd
    CD c:\mw-labs\
    ```

1. Clone the Graph Explorer repository from GitHub:

    ```cmd
    git clone https://github.com/microsoftgraph/microsoft-graph-explorer.git
    ```

1. Switch to our cloned image:

    ```cmd
    CD microsoft-graph-explorer\
    ```

1. Rename `secrets.sample.js` to `secrets.js`:

    ```cmd
    RENAME secrets.sample.js  secrets.js
    ````

1. Open `secrets.js` in Notepad:

    ```cmd
    NOTEPAD secrets.js
    ```

## Register an Application

1. Open https://apps.dev.microsoft.com.

2. Sign in using your personal Microsoft Account.

3. Select **Add an App** from the My applications section.

4. For **Application Name** enter `Graph Explorer - <your alias>`.

5. Uncheck **Guided Setup** and click **Create**.

6. Under **Platforms** select the **Add Platform** button.

7. Select **Web** as the Platform type.

8. Enter `http://localhost:3000` under **Redirect URLs**.

9. Click **Save**

10. Copy the **Application Id** to your clipboard

11. Switch to the `secrets.js` file you previously opened in Notepad 

12. Paste your copies **Application Id** into the `window.ClientId` and Save the file

## Build & Run Explorer

1. Return to your Command Prompt 

1. Download requested packaged from `npm`:

    ```cmd
    npm install
    ```
    _This process will take a minute or two. You can ignore any warnings._


1. Start Graph Explorer using `npm`:

    ```cmd
    npm start
    ```
    _At this point a browser will open automatically and open http://localhost:3000_

## Try some Samples

When the Explorer opens it will default to a demo tenant and query of `https://graph.microsoft.com/v1.0/me/`. Click **Run Query** to execute and receive this JSON result:

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",
    "id": "48d31887-5fad-4d73-a9f5-3c356e68a038",
    "businessPhones": [
        "+1 412 555 0109"
    ],
    "displayName": "Megan Bowen",
    "givenName": "Megan",
    "jobTitle": "Auditor",
    "mail": "MeganB@M365x214355.onmicrosoft.com",
    "mobilePhone": null,
    "officeLocation": "12/1110",
    "preferredLanguage": "en-US",
    "surname": "Bowen",
    "userPrincipalName": "MeganB@M365x214355.onmicrosoft.com"
}
```

### View Profile Photo  

* Try the query `https://graph.microsoft.com/v1.0/me/photo/$value` to download the user's profile photo. 

* See the meta-data for the profile photo with the query `https://graph.microsoft.com/v1.0/me/photo/$value`


### Teams & Groups

* See which Groups the user belongs too: 

    ```
https://graph.microsoft.com/v1.0/me/memberOf
    ```

* Reduce the properties returned to only `id` and `displayName`: 

    ```
https://graph.microsoft.com/v1.0/me/memberOf?$select=id,displayName
    ```

* Return which Teams the user has joined: 

    ```
https://graph.microsoft.com/beta/me/joinedTeams
    ```