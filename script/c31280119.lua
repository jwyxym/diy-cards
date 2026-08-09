--不朽机骸 天鸣巨骸
function c31280119.initial_effect(c)
	--融合召唤
	aux.AddFusionProcMix(c,false,true,c31280119.fusfilter1,c31280119.fusfilter2,c31280119.fusfilter3)
	c:EnableReviveLimit()
    --种族视为机械族
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e1:SetValue(RACE_MACHINE)
	c:RegisterEffect(e1)
	--怪兽装备    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31280119,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,31280119)
	e2:SetCondition(c31280119.condition)
	e2:SetTarget(c31280119.target)
	e2:SetOperation(c31280119.operation)
	c:RegisterEffect(e2)
	--卡片破坏    
    local e3=Effect.CreateEffect(c) 
    e3:SetDescription(aux.Stringid(31280119,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN) 
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_END_PHASE) 
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31380119)
    e3:SetCost(c31280119.cost1)
	e3:SetTarget(c31280119.target1)
	e3:SetOperation(c31280119.operation1)
	c:RegisterEffect(e3)
	--对方怪兽装备    
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(31280119,2))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c31280119.condition2)
	e4:SetTarget(c31280119.target2)
	e4:SetOperation(c31280119.operation2)
	c:RegisterEffect(e4)
end    
function c31280119.fusfilter1(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsRace(RACE_MACHINE)
end
function c31280119.fusfilter2(c)
	return c:IsSetCard(0xca2)
end
function c31280119.fusfilter3(c)
	return c:IsRace(RACE_ZOMBIE)
end
function c31280119.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsPreviousLocation(LOCATION_GRAVE)
end
function c31280119.filter(c)
	return c:IsSetCard(0xca2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c31280119.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c31280119.filter(chkc,tp) and chkc:IsControler(tp) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c31280119.filter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsFaceup() end
	if ft>2 then ft=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sg=Duel.SelectTarget(tp,c31280119.filter,tp,LOCATION_GRAVE,0,1,ft,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,#sg,0,0)
end
function c31280119.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<=0 then return end
		if g:GetCount()>ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			g=g:Select(tp,ft,ft,nil)
		end
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				Duel.Equip(tp,tc,c,true,true)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c31280119.eqlimit)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
			Duel.EquipComplete()
		end
	end
end
function c31280119.eqlimit(e,c)
	return e:GetOwner()==c
end
function c31280119.costfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function c31280119.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c31280119.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==100 then
			return Duel.IsExistingMatchingCard(c31280119.costfilter,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		else return false end
	end
	local rt=Duel.GetTargetCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c31280119.costfilter,tp,LOCATION_SZONE,0,1,rt,nil)
	local cg=Duel.SendtoGrave(g,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,cg,cg,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function c31280119.defilter(c,e)
	return c:IsRelateToEffect(e)
end
function c31280119.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(c31280119.defilter,nil,e)
	if #rg>0 then
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
function c31280119.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(1-tp) and c:IsType(TYPE_MONSTER)
end
function c31280119.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280119.cfilter,1,nil,tp)
end
function c31280119.filter1(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c31280119.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c31280119.filter1(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c31280119.filter1,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c31280119.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if not Duel.Equip(tp,tc,c,false) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c31280119.eqlimit)
		tc:RegisterEffect(e1)
	end
end