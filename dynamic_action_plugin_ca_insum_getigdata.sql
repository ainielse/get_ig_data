prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.10.15'
,p_release=>'21.2.5'
,p_default_workspace_id=>113067632160437694
,p_default_application_id=>117016
,p_default_id_offset=>0
,p_default_owner=>'ANTON'
);
end;
/
 
prompt APPLICATION 117016 - ait66
--
-- Application Export:
--   Application:     117016
--   Name:            ait66
--   Date and Time:   15:30 Tuesday April 5, 2022
--   Exported By:     ANTON
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 48402668691203991835
--   Manifest End
--   Version:         21.2.5
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/ca_insum_getigdata
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(48402668691203991835)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'CA.INSUM.GETIGDATA'
,p_display_name=>'Get IG Data'
,p_category=>'COMPONENT'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function render ',
'  ( p_dynamic_action in apex_plugin.t_dynamic_action',
'  , p_plugin         in apex_plugin.t_plugin ',
'  )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    k_crlf           varchar2(20) := chr(13) ||chr(10);',
'    l_result         apex_plugin.t_dynamic_action_render_result;',
'    l_js_val1        varchar2(32767);',
'    l_js_val2        varchar2(32767);',
'    l_columns        varchar2(32767);',
'    l_paths          varchar2(32767);    ',
'    l_console_query  varchar2(32767) := ',
'q''{',
'select',
'#COLUMNS#',
'       a.INSUM$ROW',
'  from json_table (:#ITEM# , ''$[*]''',
'         columns ',
'#PATHS#',
'           INSUM$ROW                       number         path ''$.INSUM$ROW''',
'                 ) a }''; ',
'    ',
'    --attributes',
'    l_static_id         p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_item_name         p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'    l_rows_to_return    p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_include_columns   p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_exclude_columns   p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'    ',
'    l_include           boolean;',
'    l_count             number;',
'',
'begin',
'    ',
'    --debug',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'',
'    for i in (',
'                select igc.name, igc.data_type',
'                  from APEX_APPL_PAGE_IG_COLUMNS igc',
'                  inner join apex_application_page_regions pr on pr.region_id = igc.region_id',
'                  where igc.application_id = :APP_ID',
'                    and (igc.page_id = :APP_PAGE_ID or igc.page_id = 0)',
'                    and pr.static_id = l_static_id',
'                    and igc.name not like ''APEX$%''',
'                  order by igc.display_sequence',
'             ) loop',
'        ',
'        ',
'        if l_include_columns is null then',
'            if l_exclude_columns is null then',
'                l_include := true;',
'            else',
'                select count(*)',
'                  into l_count',
'                  from table(apex_string.split(l_exclude_columns,'',''))',
'                  where trim(column_value) = i.name;',
'',
'                l_include := (l_count = 0);',
'            end if;',
'        else',
'            select count(*)',
'              into l_count',
'              from table(apex_string.split(l_include_columns,'',''))',
'              where trim(column_value) = i.name;',
'            ',
'            l_include := (l_count > 0);',
'        end if;',
'',
'        if l_include then',
'            l_js_val1 :=  l_js_val1 || '' var col'' || i.name || '' = igModel.getFieldKey("''|| i.name ||''");'' || k_crlf;',
'            l_js_val2 :=  l_js_val2 || '' igRecord.'' || i.name || '' = igRow[col''|| i.name ||''];'' || k_crlf;',
'',
'            l_columns := l_columns || ''       a.'' || i.name || '','' || k_crlf;',
'            l_paths := l_paths || ''           '' || rpad(i.name,30) || ''  varchar2(4000) path ''''$.'' || i.name || '''''','' || k_crlf;',
'        end if;',
'    end loop;',
'    ',
'    l_console_query := replace(l_console_query, ''#COLUMNS#'', rtrim(l_columns,k_crlf));',
'    l_console_query := replace(l_console_query, ''#ITEM#'', l_item_name);',
'    l_console_query := replace(l_console_query, ''#PATHS#'', rtrim(l_paths,k_crlf));',
'    ',
'    l_console_query := ''apex.debug(`'' || l_console_query || ''`);'';',
'    ',
'    l_result.javascript_function :=''function(){''',
'        ||     l_console_query',
'        ||     ''  apex.debug("getIGData"); '' || k_crlf',
'        ||     ''  var myIGArray = []; '' || k_crlf',
'        ||     ''  var igGrid = apex.region("'' || l_static_id || ''").widget().interactiveGrid("getViews").grid; '' || k_crlf        ',
'        ||     ''  var igModel = apex.region("'' || l_static_id || ''").widget().interactiveGrid("getViews", "grid").model; '' || k_crlf',
'        ||     l_js_val1  ',
'        ||     case when l_rows_to_return = ''ALL'' then',
'                        ''  var igModel2 = igModel;'' || k_crlf',
'                    else ',
'                        ''  var igModel2 = igGrid.getSelectedRecords();'' || k_crlf       ',
'                    end',
'        ||     ''  let i = 0;''',
'        ||     l_js_val1  ',
'        ||     ''igModel2.forEach(function(igRow) {''  || k_crlf',
'        ||     ''  var igRecord = new Object(); ''  || k_crlf',
'        ||     ''  i++; ''  || k_crlf',
'        ||     ''  '' || l_js_val2  || k_crlf',
'        ||     ''  igRecord.INSUM$ROW = i;''  || k_crlf',
'        ||     ''  myIGArray.push(igRecord);'' || k_crlf',
'        ||     ''});''  || k_crlf  || k_crlf',
'        ||     ''$s("'' || l_item_name || ''", JSON.stringify(myIGArray));'' || k_crlf',
'        || ''}'';',
'        ',
'    return l_result;',
'end render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Places the data from an Interactive Grid into a page item as a JSON string. That page item can then be submitted for processing as server side code within a Dynamic Action step or as an item to submit for a report region. <strong>The select statement'
||' used to process the data will be shown in the browser console.</strong> The INSUM$ROW column is always added as an indicator of the way the data was sorted at the time it was taken from the IG. An example is shown below.',
'<pre>',
'select',
'       a.ID,',
'       a.FIRST_NAME,',
'       a.LAST_NAME,',
'       a.INSUM$ROW',
'  from json_table (:P1_GRID_DATA , ''$[*]''',
'         columns ',
'           ID                              varchar2(4000) path ''$.ID'',',
'           FIRST_NAME                      varchar2(4000) path ''$.FIRST_NAME'',',
'           LAST_NAME                       varchar2(4000) path ''$.LAST_NAME'',',
'           INSUM$ROW                       number         path ''$.INSUM$ROW''',
'                 ) a ',
'</pre>',
'',
'This may be used within an "Execute PL/SQL Code" Dynamic Action as shown below:',
'',
'<pre>',
'begin',
'  for i in (',
'            select',
'              a.ID,',
'              a.FIRST_NAME,',
'              a.LAST_NAME,',
'              a.INSUM$ROW',
'            from json_table (:P1_GRID_DATA , ''$[*]''',
'                columns ',
'                  ID                              varchar2(4000) path ''$.ID'',',
'                  FIRST_NAME                      varchar2(4000) path ''$.FIRST_NAME'',',
'                  LAST_NAME                       varchar2(4000) path ''$.LAST_NAME'',',
'                  INSUM$ROW                       number         path ''$.INSUM$ROW''',
'                 ) a ',
'                        )',
'      ) loop',
'',
'    my_procedure(i.id, i.first_name, i.last_name);',
'',
'  end loop;',
'end;',
'</pre>'))
,p_version_identifier=>'0.1'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(48402682299704391089)
,p_plugin_id=>wwv_flow_api.id(48402668691203991835)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'IG Region Static ID'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter the static ID of the Interactive Grid region.</p>',
'<p>Data from the associated Interactive Grid will be placed into the identified page item as a JSON string. That page item can then be submitted for processing as server side code within a Dynamic Action step or as an item to submit for a report regi'
||'on. <strong>The select statement used to process the data will be shown in the browser console.</strong> The INSUM$ROW column is always added as an indicator of the way the data was sorted at the time it was taken from the IG. An example is shown bel'
||'ow.',
'</p>',
'<pre>',
'select',
'       a.ID,',
'       a.FIRST_NAME,',
'       a.LAST_NAME,',
'       a.INSUM$ROW',
'  from json_table (:P1_GRID_DATA , ''$[*]''',
'         columns ',
'           ID                              varchar2(4000) path ''$.ID'',',
'           FIRST_NAME                      varchar2(4000) path ''$.FIRST_NAME'',',
'           LAST_NAME                       varchar2(4000) path ''$.LAST_NAME'',',
'           INSUM$ROW                       number         path ''$.INSUM$ROW''',
'                 ) a ',
'</pre>',
'',
'This may be used within an "Execute PL/SQL Code" Dynamic Action as shown below:',
'',
'<pre>',
'begin',
'  for i in (',
'            select',
'              a.ID,',
'              a.FIRST_NAME,',
'              a.LAST_NAME,',
'              a.INSUM$ROW',
'            from json_table (:P1_GRID_DATA , ''$[*]''',
'                columns ',
'                  ID                              varchar2(4000) path ''$.ID'',',
'                  FIRST_NAME                      varchar2(4000) path ''$.FIRST_NAME'',',
'                  LAST_NAME                       varchar2(4000) path ''$.LAST_NAME'',',
'                  INSUM$ROW                       number         path ''$.INSUM$ROW''',
'                 ) a ',
'                        )',
'      ) loop',
'',
'    my_procedure(i.id, i.first_name, i.last_name);',
'',
'  end loop;',
'end;',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(48402676605506288401)
,p_plugin_id=>wwv_flow_api.id(48402668691203991835)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Item to Hold Data'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'P1_GRID_DATA'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>This DA will put JSON data from the grid into the value of this item on the page. The item can then be sent back to the database with another DA or as part of a region refresh.</p>',
'<p>This item will usually be a hidden item with protection set to "off."</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(48402671251915234068)
,p_plugin_id=>wwv_flow_api.id(48402668691203991835)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Rows to Return'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'ALL'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Indicate if all rows or only selected rows should be returned. Note: In both cases, only rows displayed on the screen will be returned.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(48402671538224235275)
,p_plugin_attribute_id=>wwv_flow_api.id(48402671251915234068)
,p_display_sequence=>10
,p_display_value=>'All Rows'
,p_return_value=>'ALL'
,p_help_text=>'Return all rows regardless of the row selector state.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(48402671946069238750)
,p_plugin_attribute_id=>wwv_flow_api.id(48402671251915234068)
,p_display_sequence=>20
,p_display_value=>'Selected Rows'
,p_return_value=>'SELECTED'
,p_help_text=>'Only return rows where the row selector is checked.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(48403016293989304873)
,p_plugin_id=>wwv_flow_api.id(48402668691203991835)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Include Columns'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'ID,FIRST_NAME,LAST_NAME'
,p_help_text=>'List of IG columns that you wish to include. If empty all columns except those listed in "Exclude Columns" will be included. Note: these are the column names/aliases that you have defined in your query or table. This list is case sensitive and will t'
||'ypically be upper case.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(48402675414113274148)
,p_plugin_id=>wwv_flow_api.id(48402668691203991835)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Exclude Columns'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>List of IG columns that you do not wish to exclude. Note: these are the column names/aliases that you have defined in your query or table. This list is case sensitive and will typically be upper case.</p>',
'<p>This value will be ignored if Include Columns is populated</p>'))
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
