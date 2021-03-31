# Time Zone Selector Item Plug-in
Oracle APEX Time Zone Selector Item Plug-in

## APEX Version
This plug-in was built, tested, and exported from APEX 20.2. It will likely work or could be rebuilt with version 5.x and higher. In the future, I will endeavor to recreate in the earliest version possible and create a branch for that version.

## Description
This plug-in will set the APEX session time zone to the user's browser time zone. It is optimized for use with the data type "timestamp with local time zone." The item can be a hidden item that does not allow the user to explicitly set the time zone, or it can be a select list that allows the user to select the time zone. Please review the help related to each setting. The item can be used on page 0 (the global page) or on one or more pages within the application. This item can be used instead of the APEX Application Globalization setting for Automatic Time Zone.

This plug-in solves two issues related to the APEX Application Globalization setting for Automatic Time Zone.

- This plug-in works with public applications.
- When used with "timestamp with local time zone," this plug-in wil the data base will recognize when to apply time zone changes due to daylight saving time.

## Installation
Import this plug-in into your application. Add the plug-in as an item on any page. (Note: this plugin can be used on Page 0 and some use cases may require that the plug-in be added twice to the same page.)

## Documentation
The plug-in includes extensive help. Please the help associated with the plug-in after adding the item to a page.
