prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_200200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2020.10.01'
,p_release=>'20.2.0.00.20'
,p_default_workspace_id=>113067632160437694
,p_default_application_id=>15008
,p_default_id_offset=>0
,p_default_owner=>'ANTON'
);
end;
/
 
prompt APPLICATION 15008 - AIT Calendar
--
-- Application Export:
--   Application:     15008
--   Name:            AIT Calendar
--   Date and Time:   21:06 Wednesday March 31, 2021
--   Exported By:     ANTON
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 45927650222508442334
--   Manifest End
--   Version:         20.2.0.00.20
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/ca_insum_tzselector
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(45927650222508442334)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'CA.INSUM.TZSELECTOR'
,p_display_name=>'Time Zone Selector'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function get_current_tz return varchar2 as',
'    l_tz    varchar2(4000);',
'begin',
'    l_tz := apex_util.get_session_time_zone;',
'',
'    if l_tz is null then',
'        l_tz := dbtimezone;',
'    end if;',
'',
'    return l_tz;',
'end get_current_tz;',
'',
'procedure render',
'  ( p_item   in            apex_plugin.t_item',
'  , p_plugin in            apex_plugin.t_plugin',
'  , p_param  in            apex_plugin.t_item_render_param',
'  , p_result in out nocopy apex_plugin.t_item_render_result ',
'  )',
'as',
'    -- attributes',
'    l_display_as        p_item.attribute_01%type := p_item.attribute_01;',
'    l_table             p_item.attribute_02%type := sys.dbms_assert.enquote_name(p_item.attribute_02, false);',
'    l_display_column    p_item.attribute_03%type := sys.dbms_assert.enquote_name(p_item.attribute_03, false);',
'    l_return_column     p_item.attribute_04%type := sys.dbms_assert.enquote_name(p_item.attribute_04, false);',
'    l_order_column      p_item.attribute_05%type := sys.dbms_assert.enquote_name(p_item.attribute_05, false);',
'    l_null_text         p_item.attribute_06%type := apex_escape.html(p_item.attribute_06);',
'    l_reload_yn         p_item.attribute_08%type := p_item.attribute_08;',
'',
'    -- constants',
'    c_value         constant varchar2(32767) := p_param.value;',
'    c_escaped_value constant varchar2(32767) := apex_escape.html(p_param.value);',
'    c_escaped_name  constant varchar2(32767) := apex_escape.html(p_item.name);',
'',
'    type t_option_xml_tab    is table of xmltype;',
'    l_option_xml_tab         t_option_xml_tab;',
'',
'    l_sql                    varchar2(32767);',
'    l_count                  number;  -- used to see if the current value exists in the select list',
'begin',
'',
'    --debug',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_item_render',
'          ( p_plugin => p_plugin',
'          , p_item   => p_item',
'          , p_param  => p_param',
'          );',
'    end if;',
'',
'    case -- render as hidden item',
'        when l_display_as = ''HIDDEN'' then',
'            htp.p(''<input type="hidden""',
'                    id="''    || c_escaped_name  || ''" ',
'                    name="''  || c_escaped_name  || ''"',
'                    value="'' || c_escaped_value || ''"',
'                    >'');',
'        -- render as select list',
'        when l_display_as = ''SL'' then',
'            htp.p(''<select',
'                    class="selectlist apex-item-select js-ignoreChange"',
'                    size="1"',
'                    id="''    || c_escaped_name  || ''" ',
'                    name="''  || c_escaped_name  || ''"',
'',
'                    >'');',
'',
'            -- add the null option to reset to browser',
'            htp.p(''<option value>'' || l_null_text || ''</option>'');                    ',
'',
'            begin <<dynamic_options>>',
'                -- check to see if the current value of the item is in the select list',
'                if c_value is not null then',
'                    l_sql := ''select count(*) ''',
'                        || ''from ''|| l_table',
'                        ||'' where rownum =1 ''',
'                        ||''   and '' || l_return_column ||'' = :1''  ;',
'',
'                    execute immediate l_sql',
'                        into l_count using c_value;',
'',
'                    -- if not found, add it to the options list as selected',
'                    if l_count = 0 then',
'                        htp.p(''<option value="'' || c_escaped_value || ''" selected="selected">'' || c_escaped_value || ''</option>'');',
'                    end if;    ',
'                end if;',
'                -- create the query to get the select list',
'                l_sql := ''select case when r = :current_val then xmlElement("option" , xmlAttributes(r as "value", ''''selected'''' as "selected"), d) ',
'                                    else xmlElement("option" , xmlAttributes(r as "value"), d) ',
'                                    end the_xml',
'                    from (select distinct ''|| l_return_column || ''  r,  '' || l_display_column ||'' d ''',
'                    || ''from ''|| l_table',
'                    ||'' where rownum < 1000 ''',
'                    ||'' order by '' || l_order_column ||'')'' ;',
'',
'                apex_debug.message(p_message        => ''CA.INSUM.TZSELECTOR - l_sql: '' || l_sql,',
'                                p_max_length     => 4000);',
'',
'                execute immediate l_sql',
'                    bulk collect into l_option_xml_tab using c_value;',
'                ',
'                -- output the select list options',
'                for i in l_option_xml_tab.first .. l_option_xml_tab.last loop',
'                    htp.p(l_option_xml_tab(i).getclobval());',
'                end loop;',
'',
'            exception',
'                when others then',
'                    htp.p(''<option value="'' || get_current_tz || ''">Invalid table or column name specified</option>'');    ',
'                    apex_javascript.add_onload_code(p_code => ''alert("Invalid table or column name specified for Time Zone Selector Plug-in");'');',
'                    apex_debug.error(p_message => ''Time Zone Selector Plug-in could not parse select list query: '' || l_sql, p_max_length => 4000);',
'            end dynamic_options;  ',
'',
'            htp.p(''</select>'');',
'        else',
'            htp.p(''<span>invalid time zone plugin display type</span>'');   ',
'        end case; ',
'',
'    if c_escaped_value is null then',
'        -- output javascript to set the time zone based upon browser setting',
'        apex_javascript.add_onload_code(p_code =>',
'                ''apex.item("'' || c_escaped_name || ''").setValue(Intl.DateTimeFormat().resolvedOptions().timeZone); ''',
'            || '' apex.server.plugin( "'' || apex_plugin.get_ajax_identifier ||''", {''',
'            || '' pageItems: "#'' || c_escaped_name || ''"''',
'            || ''}, {''',
'            || ''    success: function( data )  {''',
'            || ''        console.log("time zone set" );''',
'            -- if the plugin item is set to reload, add the javascript to reload',
'            || case when l_reload_yn = ''Y'' then '' location.reload(); ''',
'                else null',
'                end',
'            || ''},''',
'            || ''    error: function( jqXHR, textStatus, errorThrown ) {''',
'            || ''        console.log("unable to set time zone");''',
'            || ''    }''',
'            || ''}  );''',
'            );',
'    end if;',
'',
'    -- output javascript for onChange of select list option',
'    if l_display_as = ''SL'' then',
'        apex_javascript.add_onload_code(p_code =>',
'                ''$("#'' || c_escaped_name || ''").on("change", function () { ''',
'            || ''console.log("TZ change");''',
'            || ''if (($v("''|| c_escaped_name ||''")==null) || ($v("''|| c_escaped_name ||''") == "")) {''',
'            || ''    console.log("setting timezone to browser");''',
'            || ''    apex.item("'' || c_escaped_name || ''").setValue(Intl.DateTimeFormat().resolvedOptions().timeZone); ''',
'            || ''    }''',
'            || ''apex.server.plugin( "'' || apex_plugin.get_ajax_identifier ||''", {''',
'            || ''    pageItems: "#'' || c_escaped_name || ''"''',
'            || ''}, {''',
'            || ''    success: function( data )  {''',
'            || ''        console.log("time zone set" );''',
'            -- if the plugin item is set to reload, add the javascript to reload',
'            || case when l_reload_yn = ''Y'' then '' location.reload(); ''',
'                    else null',
'                    end',
'            || ''    },''',
'            || ''    error: function( jqXHR, textStatus, errorThrown ) {''',
'            || ''        console.log("unable to set time zone");''',
'            || ''    }''',
'            || ''  }  );''',
'            || ''});''',
'        );',
'    end if;   ',
' ',
'end render;',
'',
'',
'procedure ajax',
'  ( p_item   in            apex_plugin.t_item',
'  , p_plugin in            apex_plugin.t_plugin',
'  , p_param  in            apex_plugin.t_item_ajax_param',
'  , p_result in out nocopy apex_plugin.t_item_ajax_result ',
'  )',
'as',
'',
'    l_tz                varchar2(4000) := apex_util.get_session_state(p_item  => p_item.name);',
'    l_validate          p_item.attribute_07%type := p_item.attribute_07;',
'    l_count             number;',
'    l_success           varchar2(200) := ''true'';',
'begin',
'    --debug',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_item',
'          ( p_plugin => p_plugin',
'          , p_item   => p_item',
'          );',
'    end if;',
'',
'    case when l_tz is not null then',
'',
'            if l_validate = ''Y'' then',
'                -- implemented as execute immediate in case a schema does not have',
'                -- access to V$TIMEZONE_NAMES',
'                execute immediate ''select count(*) from V$TIMEZONE_NAMES where tzname = :1 and rownum = 1''',
'                    into l_count using l_tz;',
'',
'                if l_count = 0 then',
'                    l_success := ''false'';',
'                    apex_util.set_session_state(p_name  => p_item.name, p_value => get_current_tz );',
'                end if;    ',
'            end if;',
'',
'            if l_success = ''true'' then',
'                apex_util.set_session_time_zone(l_tz);',
'            end if;',
'        else',
'            apex_util.set_session_state(p_name  => p_item.name, p_value =>  get_current_tz);',
'            l_success := ''false'';',
'        end case;',
'',
'    apex_json.open_object;',
'    apex_json.write(''success'', l_success);',
'    apex_json.close_object;',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'VISIBLE:FORM_ELEMENT:SESSION_STATE:READONLY:QUICKPICK'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'This plugin will set the APEX session time zone to the user''s browser time zone. The item can be a hidden item that does not allow the user to explicitly set the time zone, or it can be a select list that allows the user to select the time zone. Plea'
||'se review the help related to each setting. The item can be used on page 0 (the global page) or on one or more pages within the application. This item can be used instead of the APEX Application Globalization setting for Automatic Time Zone.'
,p_version_identifier=>'0.1'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(45931326967724523837)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Show As'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'SL'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Note: You can place this item on the page more than once. In some cases you may wish to place two items on the page:',
'<ul>',
'<li>"Do not show this item" with "Reload on Change" enabled</li>',
'<li> "Select List" with "Reload on Change" disabled<</li>',
'</ul>',
'This would reload the page if a user enters the page without a time zone set (e.g. via a deep link to the page). However, if the user changes the select list, it would not reload the page. The next page view would have the new time zone set.'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(45931336040534528943)
,p_plugin_attribute_id=>wwv_flow_api.id(45931326967724523837)
,p_display_sequence=>10
,p_display_value=>'Do not show this item'
,p_return_value=>'HIDDEN'
,p_is_quick_pick=>true
,p_help_text=>'Do not show this item on the page. It will be a hidden item on the page.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(45931344758859532290)
,p_plugin_attribute_id=>wwv_flow_api.id(45931326967724523837)
,p_display_sequence=>20
,p_display_value=>'Select List'
,p_return_value=>'SL'
,p_is_quick_pick=>true
,p_help_text=>'Show as a Select List'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(45928477216185406830)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Source Table or View'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'V$TIMEZONE_NAMES'
,p_max_length=>256
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(45931326967724523837)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SL'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Enter the table or view that stores your available time zones. This is typically V$TIMEZONE_NAMES. Note: This is case sensitive and should typically be UPPER CASE. If you wish to limit the time zones, you could create a view such as:',
'<pre>',
'create or replace view MY_TIMEZONES as',
'select TZNAME',
'  from V$TIMEZONE_NAMES',
'  where TZNAME like ''America%''',
'</pre>',
'and then enter MY_TIMEZONES here.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(45931293186680505462)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Display Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'TZNAME'
,p_max_length=>256
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(45931326967724523837)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SL'
,p_help_text=>'Enter the column name that will be shown in the select list. This is typically TZNAME. Note: This is case sensitive and should typically be UPPER CASE.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(45931025890092465531)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Return Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'TZNAME'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(45931326967724523837)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SL'
,p_help_text=>'Enter the column name that will be returned from the select list. This is typically TZNAME. Note: This is case sensitive and should typically be UPPER CASE.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(45931857806422587794)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Order By Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'TZNAME'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(45931326967724523837)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SL'
,p_help_text=>'Enter the column name that will be used to order the select list. This is typically TZNAME. Note: This is case sensitive and should typically be UPPER CASE.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(45944096918693816226)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'"Reset to Browser" Value'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'- Use Browser Setting -'
,p_max_length=>128
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(45931326967724523837)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SL'
,p_help_text=>'The first value to be shown in the select list. This will reset the time zone to the user''s browser setting.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(46270763898930343114)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Validate Time Zone'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If enabled this will validate the value provided exists via the query "select TZNAME from V$TIMEZONE_NAMES".',
'If not enabled this will accept any time zone value provided.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(46271209490724279126)
,p_plugin_id=>wwv_flow_api.id(45927650222508442334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Reload on change'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>false
,p_help_text=>'Indicate if the page should reload when the time zone is changed. Consider enabling this when there are dates shown on the page that has this item. If there are never dates on the page that has this item, leave this disabled.'
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
