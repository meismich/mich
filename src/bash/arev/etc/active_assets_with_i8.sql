use assets;

select * from xassets, descriptions where xassets.id in (select i_asset  from descriptions where i_desctype = 13) and xassets.s_status in ( "Active" ) and xassets.id = descriptions.i_asset and descriptions.i_desctype = 13 and xassets.s_devicetype in ( "PC", "Notebook" );
