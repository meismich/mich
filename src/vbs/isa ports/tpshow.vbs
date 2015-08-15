     ' Create the root object.

    Dim root  ' The FPCLib.FPC root object

    Set root = CreateObject("FPC.Root")

 

    ' Declare the other objects needed.

    Dim isaArray     ' An FPCArray object

    Dim tpRanges     ' An FPCTunnelPortRanges collection

    Dim tpRange      ' An FPCTunnelPortRange object

 

    ' Get references to the array object

    ' and the collection of tunnel port ranges.

    Set isaArray = root.GetContainingArray()

    Set tpRanges = isaArray.ArrayPolicy.WebProxy.TunnelPortRanges

 

    ' If at least one tunnel port range is defined in the  

    ' collection, display the names and port ranges for all

    ' the tunnel port ranges.

    If tpRanges.Count > 0 Then

        For Each tpRange In tpRanges

            msgbox tpRange.Name & ": " & tpRange.TunnelLowPort & "-" & tpRange.TunnelHighPort

            if tpRange.Name = "SSL" then
		msgbox "Blah"
                'tpRange.TunnelHighPort = "444"
                'tpRange.save
            end if

        Next

    Else

        WScript.Echo "No tunnel port ranges are defined."

    End If 