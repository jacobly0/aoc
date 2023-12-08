const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
        \\
    else
        @embedFile("input");

    const Hand = struct {
        const Hand = @This();
        const ranks = "23456789TJQKA";

        cards: [5]u8,
        bid: u64,

        fn kind(hand: Hand) enum {
            high_card,
            one_pair,
            two_pair,
            three_of_a_kind,
            full_house,
            four_of_a_kind,
            five_of_a_kind,
        } {
            var cards = hand.cards;
            std.mem.sortUnstable(u8, &cards, {}, struct {
                fn lessThan(_: void, lhs: u8, rhs: u8) bool {
                    return lhs < rhs;
                }
            }.lessThan);
            if (cards[0] == cards[4]) return .five_of_a_kind;
            if (cards[0] == cards[3] or cards[1] == cards[4]) return .four_of_a_kind;
            if ((cards[0] == cards[1] and cards[2] == cards[4]) or
                (cards[0] == cards[2] and cards[3] == cards[4])) return .full_house;
            if (cards[0] == cards[2] or
                cards[1] == cards[3] or
                cards[2] == cards[4]) return .three_of_a_kind;
            if ((cards[0] == cards[1] and cards[2] == cards[3]) or
                (cards[0] == cards[1] and cards[3] == cards[4]) or
                (cards[1] == cards[2] and cards[3] == cards[4])) return .two_pair;
            if (cards[0] == cards[1] or
                cards[1] == cards[2] or
                cards[2] == cards[3] or
                cards[3] == cards[4]) return .one_pair;
            return .high_card;
        }
    };
    var hands = std.ArrayList(Hand).init(a);
    defer hands.deinit();
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var cards = line[0..5].*;
        for (&cards) |*card| card.* = @intCast(std.mem.indexOfScalar(u8, Hand.ranks, card.*).?);
        try hands.append(.{
            .cards = cards,
            .bid = try std.fmt.parseInt(u64, line[6..], 10),
        });
    }
    std.mem.sortUnstable(Hand, hands.items, {}, struct {
        fn lessThan(_: void, lhs: Hand, rhs: Hand) bool {
            var order = std.math.order(@intFromEnum(lhs.kind()), @intFromEnum(rhs.kind()));
            if (order.compare(.eq)) order = std.mem.order(u8, &lhs.cards, &rhs.cards);
            return order.compare(.lt);
        }
    }.lessThan);

    var winnings: u64 = 0;
    for (0.., hands.items) |i, hand| {
        winnings += (i + 1) * hand.bid;
    }
    std.debug.print("{}\n", .{winnings});
}
