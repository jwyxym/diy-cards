local s,id=GetID()

function s.initial_effect(c)
	-- 同调怪兽类型在制卡器中设置
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x3616),1)

	
	
	-- ①效果：种族属性变更
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetOperation(s.declop)
	c:RegisterEffect(e1)
	
	-- ②效果：对象抗性
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end

-- 限定只能用「乱世调率廻」特殊召唤
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x3616)
end
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(38040112)
end

-- ①效果：特招成功检测
function s.declop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local race=Duel.AnnounceRace(tp,1,RACE_ALL)
	-- 选择属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local attrib=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	-- 全场怪兽变更效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(race)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(attrib)
	Duel.RegisterEffect(e2,tp)
end

-- ②效果：对象抗性检测
function s.tgtg(e,c)
	local tc=e:GetHandler()
	return c==tc or (c:IsFaceup() and c:IsRace(tc:GetRace()) and c:IsAttribute(tc:GetAttribute()))
end
