--梭巡游侠诉诸结果
function c16820060.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16820060+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c16820060.sptg)
	e1:SetOperation(c16820060.spop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c16820060.drcon)
	e2:SetCost(c16820060.drcost)
	e2:SetTarget(c16820060.drtg)
	e2:SetOperation(c16820060.drop)
	c:RegisterEffect(e2)
end
function c16820060.filter(c,e,tp)
	return c:IsSetCard(0xdf28) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c16820060.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c16820060.filter,tp,0x3,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3)
end
function c16820060.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c16820060.filter,tp,0x3,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
function c16820060.cfilter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsSetCard(0xdf28) and c:IsType(0x1)
end
function c16820060.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16820060.cfilter,1,nil,tp)
end
function c16820060.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c16820060.cfilter,nil,tp)
	local sg=g:Filter(Card.IsAbleToDeckOrExtraAsCost,nil)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() and #g==#sg end
	g:AddCard(e:GetHandler())
	Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function c16820060.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c16820060.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end