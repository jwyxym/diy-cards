--白翼的慈爱·埃忒耳
function c31280175.initial_effect(c)
	--同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_FAIRY),1)
	c:EnableReviveLimit()
	--卡组特召    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280175,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,31280175)
    e1:SetCondition(c31280175.condition)
    e1:SetCost(c31280175.cost)
	e1:SetTarget(c31280175.target)
	e1:SetOperation(c31280175.operation)
	c:RegisterEffect(e1)
	--守备上升
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c31280175.value)
	c:RegisterEffect(e2)
	--效果复制
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280175,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31380175)
    e3:SetCondition(c31280175.condition2)
    e3:SetCost(c31280175.cost)
	e3:SetTarget(c31280175.target2)
	e3:SetOperation(c31280175.operation2)
	c:RegisterEffect(e3)    
	--检测对象
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(0xff)
	e4:SetOperation(c31280175.operation3)
	c:RegisterEffect(e4) 
    if not c31280175.global_check then
		c31280175.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetCondition(c31280175.checkcon)
		ge1:SetOperation(c31280175.checkop)
		Duel.RegisterEffect(ge1,0)
	end   
    Duel.AddCustomActivityCounter(31280175,ACTIVITY_SPSUMMON,c31280175.counterfilter)
end    
function c31280175.scsfilter(c)
	return not c:IsCode(31280175) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c31280175.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280175.scsfilter,1,nil)
end
function c31280175.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c31280175.scsfilter,nil)
	local tc=g:GetFirst()
	while tc do
		if Duel.GetFlagEffect(tc:GetSummonPlayer(),31280175)==0 then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),31280175,RESET_PHASE+PHASE_END,0,1)
		end
		if Duel.GetFlagEffect(0,31280175)>0 and Duel.GetFlagEffect(1,31280175)>0 then
			break
		end
		tc=g:GetNext()
	end
end
function c31280175.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_FAIRY)
end
function c31280175.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(31280175,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31280175.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c31280175.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_FAIRY)
end
function c31280175.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c31280175.tgfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsLevelBelow(5)
		and Duel.IsExistingMatchingCard(c31280175.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel(),c:GetCode())
end
function c31280175.spfilter(c,e,tp,lv,code)
	return c:IsRace(RACE_FAIRY) and c:IsLevel(lv) and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31280175.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31280175.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280175.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c31280175.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c31280175.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		local code=tc:GetCode()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c31280175.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv,code)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
        	local c=e:GetHandler()
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e1:SetTarget(c31280175.target1)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(c31280175.condition1)
			e2:SetOperation(c31280175.operation1)
			e2:SetLabelObject(tc)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)       
		end        
	end        
end        
function c31280175.target1(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
function c31280175.condition1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function c31280175.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c31280175.deffilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
function c31280175.value(e,c)
	local g=Duel.GetMatchingGroup(c31280175.deffilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
    local defup=g:GetClassCount(Card.GetCode)
	return defup*400
end
function c31280175.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,31280175)>0
end
function c31280175.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsRace(RACE_FAIRY) and c:IsType(TYPE_MONSTER) and c:IsDisabled()) then return false end
	local te=c31280175[c:GetOriginalCode()]
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function c31280175.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31280175.efffilter(chkc,e,tp) end
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExistingMatchingCard(c31280175.efffilter,tp,LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,c31280175.efffilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	Duel.ClearTargetCard()
	e:SetLabelObject(tc)
	local te=c31280175[tc:GetOriginalCode()]
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.ClearOperationInfo(0)
end
function c31280175.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local te=c31280175[tc:GetOriginalCode()]
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c31280175.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FAIRY)
end
function c31280175.operation3(e,tp,eg,ep,ev,re,r,rp)
	if not c31280175.globle_check then
		c31280175.globle_check=true
		local g=Duel.GetMatchingGroup(c31280175.filter,0,0xff,0xff,nil)
		cregister=Card.RegisterEffect
		table_effect={}
		Card.RegisterEffect=function(card,effect,flag)
			if effect and bit.band(effect:GetCode(),EVENT_SUMMON_SUCCESS)==EVENT_SUMMON_SUCCESS then
				local eff=effect:Clone()
				table.insert(table_effect,eff)
			end
			return 
		end
		for tc in aux.Next(g) do
			table_effect={}
			Duel.CreateToken(0,tc:GetOriginalCode())
			for key,eff in ipairs(table_effect) do
				c31280175[tc:GetOriginalCode()]=eff
			end
		end
		Card.RegisterEffect=cregister
	end
	e:Reset()
end