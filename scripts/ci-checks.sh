#!/usr/bin/env bash
# Sprint 1 static checks (issue #9). Runs in CI and locally: scripts/ci-checks.sh
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

failed=0
pass() { echo "✅ $1"; }
fail() { echo "❌ $1"; failed=1; }

# 1. Secret scan
if command -v gitleaks >/dev/null; then
    if gitleaks detect --source . --no-banner --redact; then pass "gitleaks: no secrets"; else fail "gitleaks found secrets"; fi
else
    fail "gitleaks is not installed (brew install gitleaks)"
fi

# 2. Sprint 1 is mock data only: no networking or Supabase
if git grep -nE "import Supabase|URLSession" -- '*.swift'; then fail "network code found"; else pass "no network code"; fi

# 3. No location permission or live position
if git grep -nE "CLLocationManager|requestWhenInUseAuthorization|requestAlwaysAuthorization|NSLocation" -- '*.swift' '*.pbxproj' '*.plist'; then
    fail "location APIs found"
else
    pass "no location APIs"
fi

# 4. "Not for navigation" disclaimer present
if git grep -qiE "not for navigation" -- '*.swift'; then pass "disclaimer present"; else fail "\"Not for navigation\" missing from Swift sources"; fi

# 5. iOS 18/26-only APIs only inside DesignSystem/ (docs/design/specs/platform-fallbacks.md)
gated='\.glassEffect\(|GlassEffectContainer|\.glassEffectID\(|buttonStyle\(\.glass(Prominent)?\)|\.tabBarMinimizeBehavior\(|\.navigationTransition\(|\.matchedTransitionSource\('
if git grep -nE "$gated" -- 'Flyby/*.swift' ':!Flyby/DesignSystem/*'; then fail "gated API outside DesignSystem/"; else pass "gated APIs wrapped in DesignSystem/"; fi

# 6. Never force-unwrap a track
if git grep -nE "\.(first|last)!" -- 'Flyby/*.swift'; then fail "force-unwrapped first/last"; else pass "no force-unwrapped first/last"; fi

# 7. .gitignore covers secrets
ignored=1
for path in .env .env.local key.p8 cert.p12 Secrets.xcconfig.local Flyby.xcodeproj/xcuserdata/ci.xcuserdatad; do
    git check-ignore -q --no-index "$path" || { fail ".gitignore does not cover $path"; ignored=0; }
done
[ $ignored -eq 1 ] && pass ".gitignore covers .env*, *.p8, *.p12, *.xcconfig.local, xcuserdata/"

# 8. Deployment target stays iOS 17.0
if grep -E "IPHONEOS_DEPLOYMENT_TARGET = " Flyby.xcodeproj/project.pbxproj | grep -qv "17.0;"; then
    fail "deployment target is not iOS 17.0"
else
    pass "deployment target iOS 17.0"
fi

exit $failed
