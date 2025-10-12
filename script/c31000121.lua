--魔风贯吼
function c31000121.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31000121)
	e1:SetTarget(c31000121.target)
	e1:SetOperation(c31000121.activate)
	c:RegisterEffect(e1)
	--return
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31000121+1)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31000121.target2)
	e2:SetOperation(c31000121.activate2)
	c:RegisterEffect(e2)
end
function c31000121.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function c31000121.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function c31000121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(c31000121.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
	local b2=Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST)
	local b3=Duel.IsExistingMatchingCard(c31000121.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.CheckRemoveOverlayCard(tp,1,0,3,REASON_COST)
	if chk==0 then return b1 end
	local opt=0
	if b1 and not b2 then
		opt=1
	elseif b1 and b2 and not b3 then
		opt=Duel.SelectOption(tp,aux.Stringid(31000121,1),aux.Stringid(31000121,2))+1
	elseif b1 and b2 and b3 then
		opt=Duel.SelectOption(tp,aux.Stringid(31000121,1),aux.Stringid(31000121,2),aux.Stringid(31000121,3))+1
	end
	e:SetLabel(opt)
	Duel.RemoveOverlayCard(tp,1,0,opt,opt,REASON_COST)
	if opt==1 or opt==2 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	elseif opt==3 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,nil,LOCATION_ONFIELD)
	end
end
function c31000121.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,c31000121.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if opt>=2 then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(c31000121.damtg)
		e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e3:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e3,tp)
	end
	if opt==3 then
		local ct=Duel.GetMatchingGroupCount(c31000121.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if ct<=0 or #g<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,ct,nil)
		if #sg>0 then
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function c31000121.damtg(e,c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x311)
end
function c31000121.rtfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x311) or c:IsType(TYPE_XYZ)) and c:IsType(TYPE_MONSTER)
end
function c31000121.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c31000121.rtfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c31000121.activate2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31000121.rtfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
