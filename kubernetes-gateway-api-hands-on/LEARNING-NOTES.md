# Gateway API Learning Notes

Use this page to record observations while completing the exercises.

## Resource responsibility

```text
GatewayClass:
Gateway:
HTTPRoute:
Service:
ReferenceGrant:
```

## Status conditions I observed

```text
GatewayClass:
Gateway:
HTTPRoute:
```

## Core troubleshooting model

```text
1. API object exists:
2. Controller accepts object:
3. References resolve:
4. Gateway is programmed:
5. Service has endpoints:
6. Runtime request matches expected rule:
```

## Traffic-management observations

```text
Weighted split sample:
Mirroring behavior:
Rewrite behavior:
TLS behavior:
Cross-namespace permission failure:
```

## Senior-engineering questions

1. Which resources should a platform team own?
2. Which resources should an application team own?
3. What prevents one namespace from targeting another namespace's Service?
4. Which behaviors need conformance testing before changing Gateway implementations?
5. Which parts should be packaged as reusable platform templates or policies?
