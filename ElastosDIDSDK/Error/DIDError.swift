import Foundation

public enum DIDError: Error {
    case unknownFailure (_ des: String?)
    case illegalArgument(_ des: String?)

    case malformedMeta  (_ des: String?)
    case malformedDID   (_ des: String?)
    case malformedDIDURL(_ des: String?)
    case malformedDocument  (_ des: String?)
    case malformedCredential(_ des: String?)
    case malformedPresentation(_ des: String?)

    case didStoreError  (_ des: String?)

    case didResolveError(_ des: String?)
    case didDeactivated (_ des: String?)
    case didExpired     (_ des: String?)
    case didtransactionError(_ des: String?)

    case invalidState   (_ des: String?)

    case notFoundError (_ des: String?)
}

extension DIDError {
    static func desription(_ error: DIDError) -> String {
        switch error {
        case .unknownFailure(let des):
            return des ?? "unknown failure"
        case .illegalArgument(let des):
            return des ?? "invalid arguments"

        case .malformedMeta(let des):
            return des ?? "malformed metadata"
        case .malformedDID(let des):
            return des ?? "malformed DID string"
        case .malformedDIDURL(let des):
            return des ?? "malformed DIDURL string"
        case .malformedDocument(let des):
            return des ?? "malformed DID document"
        case .malformedCredential(let des):
            return des ?? "malformed credential"
        case .malformedPresentation(let des):
            return des ?? "malformed presentation"

        case .didStoreError(let des):
            return des ?? "unknown didstore error"

        case .didResolveError(let des):
            return des ?? "did resolve failure"
        case .didDeactivated(let des):
            return des ?? "did was deactivated"
        case .didExpired(let des):
            return des ?? "did was expired"

        case .didtransactionError(let des):
            return des ?? "did transaction failure"

        case .invalidState(let des):
            return des ?? "invalid wrong state"

        case .notFoundError(let des):
            return des ?? "not found"
        }
    }
}
