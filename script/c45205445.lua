--王战发售：神碑之旅
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	
	--②效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x134) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.warfilter(c)
	return c:IsSetCard(0x134) and c:IsAbleToDeck()
end

function s.gravefilter(c)
	return c:IsSetCard(0x017F) and c:IsAbleToDeck()
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.warfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
	local b2=Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.warfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
		if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gravefilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
		if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			local dg=Duel.GetDecktopGroup(1-tp,1)
			if #dg>0 then
				Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
			end
			s.skipop(e,tp)
		end
	end
end

function s.skipop(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
	Duel.RegisterEffect(e1,tp)
end

return s
