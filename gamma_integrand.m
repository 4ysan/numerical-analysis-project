function q = gamma_integrand(t)
%GAMMA_INTEGRAND Evaluate the Gamma-based project integrand.
%
%   q = GAMMA_INTEGRAND(t) evaluates
%
%       q(t) = 1 / Gamma(t) - 1
%
%   for nonnegative real values of t.
%
%   At t = 0, the original formula contains Gamma(0), which is
%   not finite. However, symbolic analysis gives
%
%       lim_{t -> 0+} (1 / Gamma(t) - 1) = -1.
%
%   Therefore, the continuous extension q(0) = -1 is used.
%
%   The function supports scalar, vector, and matrix inputs.

    %% Input validation
    if ~isnumeric(t) || ~isreal(t)
        error('gamma_integrand:InvalidInput', ...
              'Input t must be a real numeric value or array.');
    end

    t = double(t);

    if any(~isfinite(t(:)))
        error('gamma_integrand:NonFiniteInput', ...
              'Input t must contain only finite values.');
    end

    if any(t(:) < 0)
        error('gamma_integrand:NegativeInput', ...
              'Input t must be nonnegative.');
    end

    %% Continuous extension at t = 0
    q = -ones(size(t));

    %% Original formula for strictly positive values
    positive_mask = (t > 0);

    if any(positive_mask(:))
        positive_t = t(positive_mask);

        q(positive_mask) = 1 ./ gamma(positive_t) - 1;
    end

    %% Output validation
    if any(~isfinite(q(:)))
        error('gamma_integrand:NonFiniteOutput', ...
              'The integrand produced NaN or Inf values.');
    end
end