--乐园妖精卡美洛物语
function c76200369.initial_effect(c)
	--change name
	aux.EnableChangeCode(c,76200372,LOCATION_HAND+LOCATION_DECK+LOCATION_SZONE+LOCATION_GRAVE) 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c76200369.catkfilter)
	e2:SetValue(c76200369.atkvalue)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76200369,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,76200369)
	e3:SetCondition(c76200369.spcon)
	e3:SetCost(c76200369.spcost)
	e3:SetTarget(c76200369.sptg)
	e3:SetOperation(c76200369.spop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(76200369,2))
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,76200369+1)
	e4:SetCondition(c76200369.drcon)
	e4:SetTarget(c76200369.drtg)
	e4:SetOperation(c76200369.drop)
	c:RegisterEffect(e4)
end
function c76200369.catkfilter(e,c)
	return c:IsRace(RACE_SPELLCASTER+RACE_DRAGON+RACE_BEASTWARRIOR+RACE_FAIRY)
end
function c76200369.atkfilter(c)
	return c:IsFaceup() and c:GetRace()~=0
end
function c76200369.atkvalue(e,c)
	local g=Duel.GetMatchingGroup(c76200369.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	return ct*200
end
function c76200369.rfilter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function c76200369.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_WATER)
end
function c76200369.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c76200369.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c76200369.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c76200369.rfilter,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,c76200369.rfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function c76200369.spfilter(c,e,tp)
	return c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c76200369.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==100 then
			return Duel.IsExistingMatchingCard(c76200369.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		else
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c76200369.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c76200369.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c76200369.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c76200369.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c76200369.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c76200369.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
function c76200369.cfilter(c,g,ct)
	return Duel.GetMZoneCount(tp,c)>0
end
function c76200369.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11738489.cfilter(chkc,lg,ct) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(c76200369.cfilter,tp,LOCATION_MZONE,0,1,c,lg,ct)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,76200369+o,0x135,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp,0,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c76200369.cfilter,tp,LOCATION_MZONE,0,1,1,c,lg,ct)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c76200369.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if not c:IsRelateToEffect(e) then return end
		local zone=bit.band(c:GetLinkedZone(tp),0x1f)
		if Duel.IsPlayerCanSpecialSummonMonster(tp,76200369+o,0x135,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP,tp,0,zone) then
			local token=Duel.CreateToken(tp,76200369+o)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end