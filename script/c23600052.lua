-- 教皇
local s,id,o=GetID()
function s.initial_effect(c)
	-- Xyz 召唤手续：包含机械族怪兽的 9 星怪兽×2只以上 (可重叠在机械族·地属性超量怪兽上)
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,7,s.ovfilter,aux.Stringid(id,0),s.xyzop)
	c:EnableReviveLimit()

	-- ①：素材有机械族超量怪兽时，攻守+900，不可被成为对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.matcon)
	e1:SetValue(900)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	e3:SetCondition(s.matcon)
	c:RegisterEffect(e3)

	-- ②：响应效果发动，拔 2 素材选场上 1 张卡送墓 (自己回合穿透全抗)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*100)
	e4:SetCost(s.tgcost)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)

	-- ③：卡被除外的场合，吸墓地/除外区的机械族怪兽做素材
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_GRAVE_ACTION)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o*200)
	e5:SetTarget(s.mttg)
	e5:SetOperation(s.mtop)
	c:RegisterEffect(e5)
end

-- 超量素材过滤：9 星怪兽
function s.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,9)
end

-- 素材组校验：必须包含至少 1 只机械族怪兽
function s.xyzcheck(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_MACHINE)
end

-- 重叠召唤过滤：机械族·地属性超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end

-- 重叠召唤 1 回合 1 次限制
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ①效果：素材包含机械族超量怪兽判断
function s.matcon(e)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(function(mc) return mc:IsRace(RACE_MACHINE) and mc:IsType(TYPE_XYZ) end,1,nil)
end

-- ②效果：Cost / Target / Operation
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	-- 自己回合发动：持有者必须送去墓地（玩家行为/REASON_RULE，穿透全抗）
	if Duel.GetTurnPlayer()==tp then
		local p=tc:GetOwner()
		Duel.SendtoGrave(tc,REASON_RULE,p)
	else
		-- 对方回合发动：一般的效果送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end

-- ③效果：墓地/除外区机械族怪兽过滤
function s.mtfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and not c:IsForbidden()
end

function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.mtfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.mtfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.mtfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end

function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc)
	end
end