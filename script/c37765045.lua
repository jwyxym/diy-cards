--苍穹魔女 梅查拉
function c37765045.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c37765045.mfilter,1,1)
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(c37765045.spcost)
	c:RegisterEffect(e0)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37765045,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	--e1:SetCountLimit(1,37765045)
	e1:SetCondition(c37765045.atkcon)
	e1:SetCost(c37765045.atkcost)
	e1:SetOperation(c37765045.atkop)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37765045)
	e2:SetCondition(Duel.IsMainPhase)
	e2:SetTarget(c37765045.cptg)
	e2:SetOperation(c37765045.cpop)
	c:RegisterEffect(e2)
	--check
	if not c37765045.global_check then
		c37765045.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_MOVE)
		ge1:SetCondition(c37765045.checkcon)
		ge1:SetOperation(c37765045.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c37765045.mfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsSummonableCard()
end
function c37765045.spcost(e,c,tp,st)
	if bit.band(st,SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	return Duel.GetFlagEffect(0,37765045)>=3
end
function c37765045.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetBattleMonster(tp)
	if not (ac and ac:IsFaceup() and ac:IsRace(RACE_PSYCHO)) then return false end
	local bc=ac:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
function c37765045.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(37765045)==0 end
	e:GetHandler():RegisterFlagEffect(37765045,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function c37765045.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ac,bc=Duel.GetBattleMonster(tp)
	if ac:IsRelateToBattle() and ac:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(bc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ac:RegisterEffect(e1)
	end
end
function c37765045.efilter(e)
	local ct=#c37765045.effect_list
	if e:GetCode()==EVENT_DESTROYED and e:IsActivated() then c37765045.effect_list[ct+1]=e end
	return false--e:IsHasRange(LOCATION_ONFIELD) and e:IsActivated()
end
function c37765045.cpfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x2a4) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()) then return false end
	c37765045.effect_list={}
	c:IsOriginalEffectProperty(c37765045.efilter)
	for _,te in ipairs(c37765045.effect_list) do
		local tg=te:GetTarget()
		if not tg or tg(e,tp,eg,ep,ev,re,r,rp,0) then return true end
	end
	return false
end
function c37765045.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37765045.cpfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp) and e:IsCostChecked() end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,c37765045.cpfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	if not tc then return end
	Duel.SendtoGrave(tc,REASON_COST)
	c37765045.effect_list={}
	tc:IsOriginalEffectProperty(c37765045.efilter)
	local e_list={}
	for _,te in ipairs(c37765045.effect_list) do
		local tg=te:GetTarget()
		if not tg or tg(e,tp,eg,ep,ev,re,r,rp,0) then table.insert(e_list,te) end--if tg and not tg(e,tp,eg,ep,ev,re,r,rp,0) then table.remove(c37765045.effect_list,i) end
	end
	local te=e_list[1]
	if #e_list>1 then
		local des_list={}
		for _,te in ipairs(e_list) do table.insert(des_list,te:GetDescription()) end
		local op=Duel.SelectOption(tp,table.unpack(des_list))
		te=e_list[op+1]
	end
	c37765045.effect_list={}
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function c37765045.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c37765045.chkfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_REMOVED) and not c:IsReason(REASON_SPSUMMON)
end
function c37765045.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37765045.chkfilter,1,nil)
end
function c37765045.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(0,37765045,RESET_PHASE+PHASE_END,0,1)
end
