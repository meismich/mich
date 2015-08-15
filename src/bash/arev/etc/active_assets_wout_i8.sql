use assets;

select * from xassets where xassets.id not in (select i_asset  from descriptions where i_desctype = 13) and xassets.s_status in ( "Active" ) and xassets.s_devicetype in ( "PC", "Notebook" );
