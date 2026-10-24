'use strict';
function publicChannel(channel, id) {
  if (!channel || channel.published !== true || channel.rightsVerified !== true) return null;
  if (channel.rightsEnd && new Date(channel.rightsEnd).getTime() <= Date.now()) return null;
  return {
    id, number: channel.number, name: channel.name, category: channel.category,
    synopsis: channel.synopsis || '', replayAllowed: channel.replayAllowed === true,
    status: channel.status === 'live' ? 'live' : 'offline'
  };
}
function guide(channels) {
  return channels.filter(Boolean).sort((a,b) => a.number-b.number || a.id.localeCompare(b.id));
}
function scheduledProgramme(p, channelId, start, end) {
  if (!p || p.channelId !== channelId || p.published !== true) return null;
  const from = new Date(p.startsAt).getTime(), to = new Date(p.endsAt).getTime();
  if (!Number.isFinite(from) || !Number.isFinite(to) || from >= to ||
      to <= start.getTime() || from >= end.getTime()) return null;
  return {id: p.id, channelId, title: p.title, synopsis: p.synopsis || '',
    startsAt: new Date(from).toISOString(), endsAt: new Date(to).toISOString()};
}
module.exports = {publicChannel, guide, scheduledProgramme};
