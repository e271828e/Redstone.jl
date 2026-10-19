/^### D-[0-9]+ — /{id=$2; inpos=0}
/^\*\*Position\.\*\*/{inpos=1}
/^\*\*(Spec|Rationale|Rejected|Divergence)\.\*\*/{inpos=0}
/^Annotation \(/{inpos=0}
inpos{print id": "$0}
