function rows = addrow(rows, row)
    if isempty(rows)
        rows = row;
    else
        rows = [rows; row];
    end
end
