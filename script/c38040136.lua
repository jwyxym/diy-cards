local s,id=GetID()

function s.initial_effect(c)
	-- 超量怪兽类型在制卡器中设置
	c:EnableReviveLimit()
	-- 超量素材要求
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x3616),7,2)
	
	
	-- ①效果：特招时叠放素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ACTIVATE_COST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.costcon)
	e1:SetCost(s.costchk)
	e1:SetOperation(s.costop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FLAG_EFFECT+id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	-- ②效果：禁止魔法陷阱发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.lockcost)
	e2:SetOperation(s.lockop)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.loccon)
	c:RegisterEffect(e4)
end

-- 限定只能用「乱世重聚廻」特殊召唤
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(38040114)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x3616)
end
function s.costcon(e)
	return e:GetHandler():GetFlagEffect(38040114)~=nil
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,LOCATION_GRAVE)
end
function s.fit1(c)
	return c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e))
end

function s.costchk(e,te_or_c,tp)
	local ct=Duel.GetFlagEffect(tp,id)
	return Duel.CheckLPCost(tp,ct*300)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,300)
end
-- ②效果：发动条件
function s.loccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)>0
end
function s.lockcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
		local g=c:GetOverlayGroup()
	e:GetHandler():RemoveOverlayCard(tp,#g,#g,REASON_COST)
end

function s.lockop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()  
	-- 禁止魔法陷阱发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	--e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	--e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(0,LOCATION_SZONE)
	e1:SetTarget(s.tg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.tg(e,c)
	return c:IsFacedown() and c:IsType(TYPE_TRAP+TYPE_SPELL)
end
