--娱乐伙伴 异色眼魔术少女
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--lv
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*100)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS_G_P)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.penfilter(c)
	return c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
--目标检查
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		--检查灵摆区域除了自己以外是否还有灵摆怪兽卡
		local pg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_PZONE,0,nil,TYPE_PENDULUM)
		if pg:GetCount()<2 then return false end
		--检查手卡和卡组是否有2只不同卡名的异色眼灵摆怪兽
		local g=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_PZONE)
end
--操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	--选择自己灵摆区域另一张灵摆怪兽卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_PZONE,0,nil,TYPE_PENDULUM)
	local dg=Group.CreateGroup()
	if c:IsLocation(LOCATION_PZONE) then
		dg:AddCard(c)
		local other=g:Filter(aux.TRUE,c):GetFirst()
		if other then
			dg:AddCard(other)
		end
	end
	if dg:GetCount()==2 and Duel.Destroy(dg,REASON_EFFECT)==2 then
		--从手卡和卡组选择2只不同卡名的异色眼灵摆怪兽
		local sg=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
		if sg:GetClassCount(Card.GetCode)>=2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tg=sg:SelectSubGroup(tp,aux.dncheck,false,2,2)
			if tg:GetCount()==2 then
				local tc1=tg:GetFirst()
				local tc2=tg:GetNext()
				--放置到灵摆区域
				if Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1) then
					if Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
						tc1:SetStatus(STATUS_EFFECT_ENABLED,true)
						if Duel.MoveToField(tc2,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
							tc2:SetStatus(STATUS_EFFECT_ENABLED,true)
						end
					end
				end
			end
		end
	end
	Duel.ResetFlagEffect(tp,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.discon)
	e1:SetValue(s.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.discon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFlagEffect(tp,id)==0
end
function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_MZONE)
end
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(0x9f,0x98) and c:GetPreviousCodeOnField()~=id
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp) and e:GetHandler():IsFaceup() and not eg:IsContains(e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsLocation(LOCATION_EXTRA) then
			return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		else
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.lvfilter(c,lv,olv)
	local clv=c:GetOriginalLevel()
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGrave() and c:IsFaceup() and clv~=olv and math.abs(clv-olv)~=lv
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsLevelAbove(0)
			and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel(),c:GetOriginalLevel())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_EXTRA,0,1,1,nil,c:GetLevel(),c:GetOriginalLevel())
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(math.abs(c:GetOriginalLevel()-tc:GetOriginalLevel()))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
