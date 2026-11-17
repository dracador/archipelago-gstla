# stuff from the hacking doc:

# for chars
EWRAM_OFFSET = 0x02000520
CHARACTER_BLOCK_SIZE = 0x14C
CHARACTER_BLOCK_START = 0x520  # 0x02000520

HP_RATIO_OFFSET = 0x14
MAX_HP_OFFSET = 0x34
CURRENT_HP_OFFSET = 0x38

DJINN_OFFSET = 0xF8

FELIX_START_ADDR = 0x520 + 4 * 0x14C  # 0xA50
FELIX_CURRENT_HP = FELIX_START_ADDR + CURRENT_HP_OFFSET  # 0xA88, correct, whee
FELIX_DJINNS = FELIX_START_ADDR + DJINN_OFFSET  # 0xB48


# Karanum-Rando uses these, both blocksize 2
# maybe bc savefile saves it, too?
RANDO_ITEMS_RECEIVED_COUNTER_OFFSET = 0x22  # 0xA72 + 0xA73
RANDO_ITEMS_MAILBOX_OFFSET = 0x46  # 0xA96 + 0xA97


DJINN_PER_ELEMENT = 18  # (0x12), ROM
DJINN_MAPPING_TABLE_ADDR = 0xFA0000  # ROM (the patched table, 4 * 18 * 2 bytes)
DJINN_FLAG_START = 0x30  # 48, EWRAM
DJINN_FLAGS_PER_ELEMENT = 20  # (0x14), EWRAM
DJINN_FLAGS_LENGTH = 4 * DJINN_FLAGS_PER_ELEMENT // 8  # 10 bytes
DJINN_COUNT = 4 * DJINN_PER_ELEMENT

from enum import IntEnum
class ElementType(IntEnum):
    Earth = 0
    Water = 1
    Fire = 2
    Air = 3


def djinn_to_flag_index(element: int, index: int) -> int:
    # (ElementType.Earth, index 0) == 40 (or 0x30)
    return DJINN_FLAG_START + element * DJINN_FLAGS_PER_ELEMENT + index


def flag_index_to_djinn(flag: int) -> tuple[ElementType, int]:
    # 111 = ElementType.Air + ID 3 = Smog
    offset = flag - DJINN_FLAG_START
    element, index = divmod(offset, DJINN_FLAGS_PER_ELEMENT)
    if index >= DJINN_PER_ELEMENT:
        raise ValueError(f'Djinn flag at {hex(flag)} unused')
    return ElementType(element), index

# okay, I want the first djinn to look like this:
# 0XB00
# so we can encode the element and index directly in there as the last two values.
# So: Element 3, Djinn 18  = 0x0B312, where the first value after 0xB is the element and the rest is the hex of djinn nr
# 0xB312
#
# ABOVE IS DUMB, THIS IS BETTER:
# 0x0B00
# 2 << 5 = 0x40 / 0100 0000
# 17 = 0x11     / 0001 0001
# get OR'd      / 0101 0001 == 0x51
