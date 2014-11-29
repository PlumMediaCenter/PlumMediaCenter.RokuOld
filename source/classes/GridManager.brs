function GridManager()
   return {
        'a 2D aray of rows and columns
        rows: CreateObject("roArray", 0, true),
        titles:  CreateObject("roArray", 0, true),
        '''
        ' Adds a row of data
        '''
        addRow: function(title, columns)
                m.titles.push(title)
                m.rows.push(columns)
            end function,
        '''
        ' Overwrites the item at the specified row number 
        '''
        setRow: function(rowNumber, title, columns)
            titles[rowNumber] = title
            rows[rowNumber] = columns
        end function,
        '''
        ' Gets the item at the specified row and column
        '''
        getItem: function(rowNumber, columnNumber)
                row = m.rows[rowNumber]
                if row <> invalid
                    return row[columnNumber]
                else
                    return invalid
                end if
            end function,
        draw: function(roGridScreen)
                roGridScreen.SetupLists(m.titles.Count())
                roGridScreen.SetListNames(m.titles) 
                for i = 0 to m.rows.count() - 1 step 1
                    row = m.rows[i]
                    roGridScreen.SetContentList(i, row) 
                end for
            end function
        
    }
end function