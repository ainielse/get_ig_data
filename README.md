# Get IG Data Dynamic Action Plug-in
Oracle APEX Get IG Data Dynamic Action Plug-in

## APEX Version
This plug-in was built, tested, and exported from APEX 20.1.

## Description
Places the data from an Interactive Grid into a page item as a JSON string. That page item can then be submitted for processing as server side code within a Dynamic Action step or as an item to submit for a report region. **The select statement used to process the data will be shown in the browser console.** The INSUM$ROW column is always added as an indicator of the way the data was sorted at the time it was taken from the IG. An example is shown below.
```
select
       a.ID,
       a.FIRST_NAME,
       a.LAST_NAME,
       a.INSUM$ROW
  from json_table (:P1_GRID_DATA , '$[*]'
         columns 
           ID                              varchar2(4000) path '$.ID',
           FIRST_NAME                      varchar2(4000) path '$.FIRST_NAME',
           LAST_NAME                       varchar2(4000) path '$.LAST_NAME',
           INSUM$ROW                       number         path '$.INSUM$ROW'
                 ) a 
```

This may be used within an "Execute PL/SQL Code" Dynamic Action as shown below:

```
begin
  for i in (
            select
              a.ID,
              a.FIRST_NAME,
              a.LAST_NAME,
              a.INSUM$ROW
            from json_table (:P1_GRID_DATA , '$[*]'
                columns 
                  ID                              varchar2(4000) path '$.ID',
                  FIRST_NAME                      varchar2(4000) path '$.FIRST_NAME',
                  LAST_NAME                       varchar2(4000) path '$.LAST_NAME',
                  INSUM$ROW                       number         path '$.INSUM$ROW'
                 ) a 
                        )
      ) loop

    my_procedure(i.id, i.first_name, i.last_name);

  end loop;
end;
```
## Installation
Import this plug-in into your application. 

## Usage
Create a page with an Interactive Grid. Add a Static ID to the IG region. Create a hidden item with protection turned off. Add the plug-in as Dynamic Action step associated with a button (or other event). After triggering the event, inspect the console to obtain the SQL query associated with the data.
As an example of how it works, create an Interactive Report using the query obtained from the console. Be sure to add the hidden item as a Page Item to Submit with the IR. Add a final step to the Dynamic action that refreshes the IR report region. 

## Documentation
The plug-in includes extensive help. Please see the help associated with the plug-in after adding it to a page.

## Known Issues
If you have an IG on Page Zero (0), it needs to have a globally unique static ID. If it shares a static ID with an IG on another page, this plug-in could get confused. It is possible to fix this, but I'm unlikely to do so, as, really, if you have a static ID on Page 0, it really should be globally unique anyway.
