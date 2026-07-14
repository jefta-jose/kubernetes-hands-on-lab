# Concept Map

## Storage lifecycle hierarchy

```text
Container filesystem
└── Lost when the container is replaced

emptyDir
└── Survives container restart
    └── Lost when the Pod is deleted

hostPath
└── Stored on one worker node
    └── Not portable across nodes

PersistentVolumeClaim
└── Storage lifecycle is independent of one Pod
    └── Can be remounted by a replacement Pod
```

## Configuration delivery

```text
ConfigMap -> environment variable
          -> mounted file

Secret    -> environment variable
          -> mounted file

Downward API -> environment variable
             -> mounted file

Projected volume -> combines multiple file sources
```

## Design questions

Before choosing a volume, ask:

1. Must the data survive a container restart?
2. Must it survive Pod deletion?
3. Must it survive node failure?
4. Is it authoritative or rebuildable?
5. Is it sensitive?
6. Is access read-only or read-write?
7. Does one container, one Pod, or many Pods need it?
8. How will it be backed up?
9. How will configuration changes be activated?
10. What is the security blast radius?
