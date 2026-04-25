import ProjectDescription

let tuist = Tuist(
    fullHandle: "shotofvodkah/Gymbro",
    project: .tuist(
        generationOptions: .options(optionalAuthentication: true)
    )
)