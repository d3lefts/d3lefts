function export_costep_arrays(time_s, measurements, signal_names, outfile)
% Source-neutral, fail-closed MATLAB export for a PREVALIDATED COSTEP run.
% Does NOT set up or run COSTEP, infer a source format, or authenticate outputs.
% Call only with numeric arrays extracted and inspected from the chosen model.
% A separate signed experiment manifest must record model commit/controller/fault/seed.
    arguments
        time_s (:,1) double
        measurements (:,:) double
        signal_names (1,:) string
        outfile (1,1) string
    end
    n = numel(time_s);
    if n < 4 || size(measurements,1) ~= n
        error('Rows must align exactly with the vector of timestamps.');
    end
    if size(measurements,2) ~= numel(signal_names) || numel(signal_names) < 1
        error('Signal names and measurement width disagree.');
    end
    if any(~isfinite(time_s)) || any(diff(time_s) <= 0) || any(~isfinite(measurements),'all')
        error('Nonfinite values or nonincreasing timestamps.');
    end
    signal_names = matlab.lang.makeValidName(signal_names);
    if numel(unique(signal_names)) ~= numel(signal_names) || any(signal_names == "time_s")
        error('Duplicate or reserved signal column names.');
    end
    T = array2table(measurements,'VariableNames',cellstr(signal_names));
    T = addvars(T,time_s,'Before',1,'NewVariableNames','time_s');
    writetable(T,outfile);
end
