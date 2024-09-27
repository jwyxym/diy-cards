--最初的晶光
function c11100016.initial_effect(c)
		--link summon
	aux.AddLinkProcedure(c,c11100016.matfilter,1,1)
	c:EnableReviveLimit()
end
function c11100016.matfilter(c)
	return c:IsLinkSetCard(0xa60)
end
