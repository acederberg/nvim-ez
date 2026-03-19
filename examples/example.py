"""This is here so that it can be verified that reStructuredText is coorectly
detected and highlighted.

.. This should be a comment.

.. code:: python

    print("It works!")


.. code:: javascript

    console.log("This is some javascript.")

"""

# =========================================================================== #
# NOTE: This section is taken from ``captura.client.flags``.
#
import enum
import json
import pathlib
from datetime import datetime
from typing import Annotated, Any, Dict, List, Optional, TypeAlias

import typer

# --------------------------------------------------------------------------- #
from app.fields import PendingFromStr
from app.models import (
    ChildrenCollection,
    ChildrenDocument,
    ChildrenUser,
    KindEvent,
    KindObject,
    KindRecurse,
    LevelStr,
)


class Verbage(str, enum.Enum):
    read = "read"
    # TODO: Depricate the two bellow.
    read_document = "read_document"
    read_user = "read_user"

    search = "search"
    restore = "restore"
    update = "update"
    delete = "delete"
    create = "create"
    activate = "activate"

    # apply = "apply"
    # destroy = "destroy"


class Output(str, enum.Enum):
    raw = "raw"
    json = "json"
    yaml = "yaml"
    table = "table"


# --------------------------------------------------------------------------- #
# UUID Flags and Arguments
# NOTE: Annotations should eventually include help.

FlagOutput: TypeAlias = Annotated[Output, typer.Option("--output", "-o")]
FlagUUIDs: TypeAlias = Annotated[Optional[List[str]], typer.Option("--uuid")]


# User

ArgUUIDUser: TypeAlias = Annotated[str, typer.Argument(help="User uuid.")]
FlagUUIDUserOptional: TypeAlias = Annotated[
    Optional[str],
    typer.Option(
        "--uuid-user",
        help="Transfer ownship of a collection to this UUID.",
    ),
]
FlagUUIDUsers: TypeAlias = Annotated[
    List[str],
    typer.Option(
        "--uuid-user",
        help="A required list of user UUIDs.",
    ),
]
FlagUUIDUsersOptional: TypeAlias = Annotated[
    Optional[List[str]],
    typer.Option(
        "--uuid-user",
        help="An optional list of user UUIDs.",
    ),
]

FlagInvitationCode: TypeAlias = Annotated[
    str,
    typer.Option(
        "--invitation-code",
        help="The invitation code to approve/verify a demo user with.",
    ),
]
FlagInvitationEmail: TypeAlias = Annotated[
    str,
    typer.Option(
        "--invitation-email",
        help="The email corresponding the invitation code.",
    ),
]
FlagInvitationCodesOptional: TypeAlias = Annotated[
    Optional[List[str]],
    typer.Option(
        "--invitation-code",
        help="Invitation codes to search by.",
    ),
]
FlagInvitationEmailsOptional: TypeAlias = Annotated[
    Optional[List[str]],
    typer.Option(
        "--invitation-email",
        help="Invitation emails to search by.",
    ),
]


# --------------------------------------------------------------------------- #
# Documents

FlagUUIDDocuments: TypeAlias = Annotated[
    List[str],
    typer.Option("--uuid-document", help="Document uuids."),
]
FlagUUIDDocumentsOptional: TypeAlias = Annotated[
    Optional[List[str]],
    typer.Option(
        "--uuid-document",
        help="Optional document uuids.",
    ),
]
ArgUUIDDocument: TypeAlias = Annotated[str, typer.Argument()]


# --------------------------------------------------------------------------- #
# Collections

FlagUUIDCollections: TypeAlias = Annotated[List[str], typer.Option("--uuid-collection")]
FlagUUIDCollectionsOptional: TypeAlias = Annotated[
    List[str], typer.Option("--uuid-collection")
]
ArgUUIDCollection: TypeAlias = Annotated[str, typer.Argument()]


# --------------------------------------------------------------------------- #
# Events

FlagUUIDEvent = Annotated[str, typer.Option("--uuid-event")]
FlagUUIDEventOptional = Annotated[Optional[str], typer.Option("--uuid-event")]
FlagUUIDEvents = Annotated[List[str], typer.Option("--uuid-event")]
FlagUUIDEventsOptional = Annotated[Optional[List[str]], typer.Option("--uuid-event")]


# --------------------------------------------------------------------------- #
# Field flags

FlagColumns: TypeAlias = Annotated[List[str], typer.Option("--column")]
FlagLevel: TypeAlias = Annotated[LevelStr, typer.Option("--level")]

FlagName = Annotated[str, typer.Option("--name")]
FlagNameOptional = Annotated[Optional[str], typer.Option("--name")]

FlagDescription = Annotated[str, typer.Option("--description")]
FlagDescriptionOptional = Annotated[Optional[str], typer.Option("--description")]
FlagUrlOptional = Annotated[Optional[str], typer.Option("--url")]
FlagUrlImageOptional = Annotated[Optional[str], typer.Option("--url-image")]

FlagPublic = Annotated[bool, typer.Option("--public/--private")]
FlagPublicOptional = Annotated[Optional[bool], typer.Option("--public/--private")]
FlagForce = Annotated[bool, typer.Option("--force/--no-force")]
FlagKindRecurse: TypeAlias = Annotated[KindRecurse, typer.Option("--recurse-strategy")]

# FlagContentOptional: TypeAlias = Annotated[Optional[str], typer.Option("--content")]
# FlagMessageOptional: TypeAlias = Annotated[Optional[str], typer.Option("--message")]
# FlagContent: TypeAlias = Annotated[str, typer.Option("--content")]
# FlagMessage: TypeAlias = Annotated[str, typer.Option("--message")]

# --------------------------------------------------------------------------- #
# Search flags


FlagNameLike: TypeAlias = Annotated[Optional[str], typer.Option("--name-like")]
FlagDescriptionLike: TypeAlias = Annotated[
    Optional[str], typer.Option("--description-like")
]
FlagIncludePublic: TypeAlias = Annotated[int, typer.Option("--include-public")]
FlagLimit: TypeAlias = Annotated[int, typer.Option("--limit")]
FlagLimitOptional: TypeAlias = Annotated[Optional[int], typer.Option("--limit")]


# --------------------------------------------------------------------------- #
# Children flags

FlagChildrenUser: TypeAlias = Annotated[
    Optional[ChildrenUser], typer.Option("--child", "--children")
]
FlagChildrenCollection: TypeAlias = Annotated[
    ChildrenCollection, typer.Option("--child", "--children")
]
FlagChildrenDocument: TypeAlias = Annotated[
    ChildrenDocument, typer.Option("--child", "--children")
]


# --------------------------------------------------------------------------- #
# Events flags

ArgUUIDEvent: TypeAlias = Annotated[str, typer.Argument()]
FlagFlatten: TypeAlias = Annotated[
    bool,
    typer.Option(
        "--flatten/--heads",
        help="Return only heads (entries with no parents).",
    ),
]
FlagKind: TypeAlias = Annotated[
    Optional[KindEvent],
    typer.Option("--kind", "-k", help="Matches against the `kind` field."),
]

ArgKindObject: TypeAlias = Annotated[
    KindObject,
    typer.Argument(help="Object kind, matches again the `kind_obj` field."),
]
FlagKindObject: TypeAlias = Annotated[
    KindObject,
    typer.Option(
        "--object",
        "-j",
        help="Object kind, matches again the `kind_obj` field.",
    ),
]
FlagKindObjectOptional: TypeAlias = Annotated[
    Optional[KindObject],
    typer.Option(
        "--object",
        "-j",
        help="Object kind, matches again the `kind_obj` field.",
    ),
]

ArgUUIDEventObject: TypeAlias = Annotated[
    str, typer.Argument(help="Target object uuid.")
]

FlagUUIDEventObject: TypeAlias = Annotated[
    str,
    typer.Option(
        "--uuid-object",
        "--uuid",
        help="Target object UUID.",
    ),
]
FlagUUIDEventObjectOptional: TypeAlias = Annotated[
    Optional[str],
    typer.Option(
        "--uuid-object",
        "--uuid",
        help="Target object UUID.",
    ),
]
FlagBefore = Annotated[Optional[datetime], typer.Option("--before")]
FlagAfter = Annotated[Optional[datetime], typer.Option("--after")]

# --------------------------------------------------------------------------- #
# Configuration Flags.

FlagConfig: TypeAlias = Annotated[
    Optional[str],
    typer.Option("--config", help="Configuration to use everywhere."),
]

FlagHost: TypeAlias = Annotated[
    Optional[str],
    typer.Option(
        "--host",
        help="Host from configuration to use.",
    ),
]
FlagProfile: TypeAlias = Annotated[
    Optional[str],
    typer.Option(
        "--profile",
        "-p",
        help="Profile from configuration to use.",
    ),
]

# --------------------------------------------------------------------------- #
# Loader flags.

ArgFilePath: TypeAlias = Annotated[
    pathlib.Path,
    typer.Argument(help="Path to the apply file."),
]

# --------------------------------------------------------------------------- #
# Token flags

FlagTokenOptional: TypeAlias = Annotated[
    Optional[str], typer.Option(help="Specifies the token to use for any request.")
]

FlagAdmin: TypeAlias = Annotated[
    Optional[bool],
    typer.Option("--admin/--not-an-admin", help="Admin token or not an admin token"),
]

ArgTokenPayload: TypeAlias = Annotated[
    str, typer.Option("--payload", help="Data for token payload.")
]

FlagPending: TypeAlias = Annotated[
    bool,
    typer.Option("--pending", help="Get only pending grants."),
]

FlagOpenApi: TypeAlias = Annotated[
    bool,
    typer.Option(
        "--openapi", help="Get the OpenAPI information for the specified request."
    ),
]

FlagShowRequest: TypeAlias = Annotated[
    bool,
    typer.Option(
        "--request-show",
        help="Show the full request (still executes request).",
    ),
]

FlagPendingFromOptional: TypeAlias = Annotated[
    Optional[PendingFromStr],
    typer.Option("--pending-from", help="Filter results by their pending from status."),
]

FlagNoAuthorization: TypeAlias = Annotated[
    bool,
    typer.Option(
        "--auth-exclude/--auth-include",
        help="Include or exclude the authorization header.",
    ),
]


def check_content(v: str, allow_none: bool = False):
    if allow_none and v is None:
        return v

    decoded = json.loads(v)
    if allow_none and decoded is None:
        return v

    assert isinstance(decoded, dict)
    return decoded


FlagContent: TypeAlias = Annotated[
    str,
    typer.Option(
        "--content",
        help="Content.",
        callback=check_content,
    ),
]
FlagContentOptional: TypeAlias = Annotated[
    Optional[str],
    typer.Option(
        "--content",
        help="Content.",
        callback=lambda v: check_content(v, allow_none=True),
    ),
]
FlagEmail: TypeAlias = Annotated[
    Optional[str], typer.Option("--email", help="Email address.")
]

FlagDecorate = Annotated[Optional[bool], typer.Option("--decorate/--no-decorate")]
# FlagExclude - Annotated[Optional[List[str]], typer.Option
