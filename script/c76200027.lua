--极雪魔境的魔女王
local cm,m,o=GetID()
function cm.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(cm.sfilter),nil,nil,aux.Tuner(Card.IsSetCard,0x720),1,99)
	c:EnableReviveLimit()
	--change name
	aux.EnableChangeCode(c,76200009,LOCATION_MZONE+LOCATION_GRAVE)
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(cm.eqcon)
	e1:SetTarget(cm.eqtg)
	e1:SetOperation(cm.eqop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,m+17)
	e2:SetTarget(cm.tetg)
	e2:SetOperation(cm.teop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m+16)
	e3:SetCondition(cm.spcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(cm.sptg)
	e3:SetOperation(cm.spop)
	c:RegisterEffect(e3)
end
function cm.sfilter(c)
	return c:IsSetCard(0x720) and c:IsType(TYPE_SYNCHRO)
end
function cm.tefilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup()
end
function cm.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(cm.tefilter,tp,LOCATION_SZONE,0,nil)
	local dam=g:GetCount()*300
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function cm.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	local g=Duel.GetMatchingGroup(cm.tefilter,tp,LOCATION_SZONE,0,nil)
	if g then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=g:GetCount()*300
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end

function cm.eqfilter1(c,e)
	return c:IsSetCard(0x720) and c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(cm.eqfilter,c:GetControler(),LOCATION_DECK+LOCATION_GRAVE,0,1,c,e,c:GetControler())
end
function cm.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.eqfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.eqfilter1,tp,LOCATION_MZONE,0,1,nil,e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,cm.eqfilter1,tp,LOCATION_MZONE,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cm.eqfilter(c,e,tp)
	return ((c:IsType(TYPE_MONSTER) and c:IsSetCard(0x720)) or c:IsType(TYPE_EQUIP)) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function cm.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(cm.eqfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.eqfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,c,e,tp)
			if g then
				local tc=g:GetFirst()
				while tc do
					if Duel.Equip(tp,tc,c,false) and tc:GetOriginalType()&TYPE_MONSTER~=0 then
						local e1=Effect.CreateEffect(c)
						e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_EQUIP_LIMIT)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						e1:SetValue(cm.eqlimit)
						tc:RegisterEffect(e1)
					end
				tc=g:GetNext()
				end
			end
		end
	end
end
function cm.eqlimit(e,c)
	return e:GetOwner()==c
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function cm.spfilter(c,e,tp)
	return c:IsSetCard(0x720) and c:IsLevelAbove(1) and c:IsLevelBelow(11) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
	and Duel.IsExistingMatchingCard(cm.spfilter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c,12-c:GetLevel())
end
function cm.spfilter1(c,e,tp,ec,lv)
	local sc=e:GetHandler()
	local a=0
	local b=0
	if sc:IsLocation(LOCATION_MZONE) and sc:GetSequence()>4 then a=a+1
	elseif sc:IsLocation(LOCATION_MZONE) and sc:GetSequence()<=4 then b=b+1
	else end
	local g=Duel.GetLocationCountFromEx(tp,tp,nil,c,0x0060)+a
	local g1=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,0x001f)+b
	return c:IsSetCard(0x720) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and ((c:IsLocation(LOCATION_DECK) and ec:IsLocation(LOCATION_DECK) and g1>=2)
			or (c:IsLocation(LOCATION_EXTRA) and ec:IsLocation(LOCATION_EXTRA) and g+g1>=2)
			or (c:IsLocation(LOCATION_EXTRA) and ec:IsLocation(LOCATION_DECK) and g+g1>=2)
			or (c:IsLocation(LOCATION_DECK) and ec:IsLocation(LOCATION_EXTRA) and g+g1>=2)
		)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local g=Duel.GetLocationCountFromEx(tp,tp,nil,c,0x0060)
	local g1=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,0x001f)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,cm.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local tc1=Duel.SelectMatchingCard(tp,cm.spfilter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc,12-tc:GetLevel()):GetFirst()
	if tc:IsLocation(LOCATION_DECK) and tc1:IsLocation(LOCATION_EXTRA) and g1==1 and g==1 then
		Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP,0x001f)
		Duel.SpecialSummonStep(tc1,0,tp,tp,true,false,POS_FACEUP,0x0060)
		Duel.SpecialSummonComplete()
	elseif tc:IsLocation(LOCATION_EXTRA) and tc1:IsLocation(LOCATION_DECK) and g1==1 and g==1 then
		Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP,0x0060)
		Duel.SpecialSummonStep(tc1,0,tp,tp,true,false,POS_FACEUP,0x001f)
		Duel.SpecialSummonComplete()
	else 
		Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
		Duel.SpecialSummonStep(tc1,0,tp,tp,true,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end