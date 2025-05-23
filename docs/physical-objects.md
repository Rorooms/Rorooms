---
sidebar_position: 5
---

# Physical Objects

Apply these tags onto Studio instances to add easy, no-code functionality within your world. Tags can be applied from within the Properties panel.

## Animated Seats 🪑

Seats that support custom sitting animations, and prompt-to-sit functionality. It's recommended to use this on all seat objects for a better user experience.

<details>
<summary>Details</summary>
<br />

| Data        | Value             |
| ----------- | ----------------- |
| `Tag`       | `RR_AnimatedSeat` |
| `ClassName` | `Seat`            |

| Attribute        | Type      | Optional |
| ---------------- | --------- | -------- |
| `RR_PromptToSit` | `boolean` | ✅        |

### Children

- "Animation" - `Animation`

</details>

## Animated Items 🔧

Tools that support click-to-cycle animations.

<details>
<summary>Details</summary>
<br />

| Data        | Value             |
| ----------- | ----------------- |
| `Tag`       | `RR_AnimatedItem` |
| `ClassName` | `Tool`            |

### Children

Animations must be arranged in numerical order.

- "RR_ItemAnimations" - `Folder`
- - "1" - `Animation`
- - "2" - `Animation`
- - "..." - `Animation`

</details>

## Item Givers 🫴

Prompt parts that give out items.

<details>
<summary>Details</summary>
<br />

| Data        | Value          |
| ----------- | -------------- |
| `Tag`       | `RR_ItemGiver` |
| `ClassName` | `BasePart`     |

| Attribute   | Type     | Optional |
| ----------- | -------- | -------- |
| `RR_ItemId` | `string` | ❌        |

</details>

## Variant Cyclers 🔁

Prompt parts that cycle between various models.

<details>
<summary>Details</summary>
<br />

| Data        | Value              |
| ----------- | ------------------ |
| `Tag`       | `RR_VariantCycler` |
| `ClassName` | `BasePart`         |

### Children

Variant models must be arranged in numerical order.

- "1" - `Model`
- "2" - `Model`
- "..." - `Model`

</details>

## Locked Zones 🔒

Locked zones are parts that prevent players from being within them based on certain criteria.

<details>
<summary>Details</summary>
<br />

| Data        | Value           |
| ----------- | --------------- |
| `Tag`       | `RR_LockedZone` |
| `ClassName` | `BasePart`      |

| Attribute             | Type     | Optional |
| --------------------- | -------- | -------- |
| `LevelRequirement`    | `number` | ✅        |
| `GamepassRequirement` | `number` | ✅        |

</details>

## Locked Doors 🔒

Locked doors are parts that prevent players from walking through them based on certain criteria.

<details>
<summary>Details</summary>
<br />

| Data        | Value           |
| ----------- | --------------- |
| `Tag`       | `RR_LockedDoor` |
| `ClassName` | `BasePart`      |

| Attribute             | Type     | Optional |
| --------------------- | -------- | -------- |
| `LevelRequirement`    | `number` | ✅        |
| `GamepassRequirement` | `number` | ✅        |

</details>

## World Teleporters 🌐

Parts that prompt teleports to other RoRooms worlds.

<details>
<summary>Details</summary>
<br />

| Data        | Value                |
| ----------- | -------------------- |
| `Tag`       | `RR_WorldTeleporter` |
| `ClassName` | `BasePart`           |

| Attribute    | Type     | Optional |
| ------------ | -------- | -------- |
| `RR_PlaceId` | `number` | ❌        |

</details>