'use strict';
/**
 * Capability gate only. No stream recording is performed by this module.
 * Player UI must never offer DVR just because a generic channel is playable.
 */
function dvrCapabilities(channel, subscription, now = new Date()) {
  const authorized = Boolean(channel?.rightsVerified && channel?.published &&
    channel?.replayAllowed && channel?.dvrProviderEnabled &&
    subscription?.status === 'active' &&
    ['TV','ISP_TV_BUNDLE'].includes(subscription.product));
  const until = channel?.rightsEnd ? new Date(channel.rightsEnd) : null;
  const rightsValid = !until || (Number.isFinite(until.getTime()) && until > now);
  return {restart:authorized && rightsValid,record:authorized && rightsValid &&
    channel.recordingAllowed === true};
}
module.exports={dvrCapabilities};
