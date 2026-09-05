-- 混沌No.102 圣光天使 圣天 (ID: 20263245)
local s,id,o=GetID()
local SET_NUMBER=0x48 -- 「No.」官方字段代码

function s.initial_effect(c)
	-- Xyz 召唤手续：5星怪兽 × 4
	aux.AddXyzProcedure(c,nil,5,4)
	c:EnableReviveLimit()

	-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把这张卡的1个超量素材取除
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)

	-- ②：只要这张卡在场上存在，自己受到的效果伤害变为0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)
	local e2_2=e2:Clone()
	e2_2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2_2)

	-- ③：只要持有「No.」素材在场存在，对方场上攻击表示怪兽攻击力变0，且不能作为融合·同调·超量·连接素材
	-- 攻击力变为0
	local e3_atk=Effect.CreateEffect(c)
	e3_atk:SetType(EFFECT_TYPE_FIELD)
	e3_atk:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3_atk:SetRange(LOCATION_MZONE)
	e3_atk:SetTargetRange(0,LOCATION_MZONE)
	e3_atk:SetCondition(s.numcon)
	e3_atk:SetTarget(s.atktg)
	e3_atk:SetValue(0)
	c:RegisterEffect(e3_atk)

	-- 封锁融合素材
	local e3_mat1=Effect.CreateEffect(c)
	e3_mat1:SetType(EFFECT_TYPE_FIELD)
	e3_mat1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3_mat1:SetRange(LOCATION_MZONE)
	e3_mat1:SetTargetRange(0,LOCATION_MZONE)
	e3_mat1:SetCondition(s.numcon)
	e3_mat1:SetTarget(s.atktg)
	e3_mat1:SetValue(1)
	c:RegisterEffect(e3_mat1)

	-- 封锁同调素材
	local e3_mat2=e3_mat1:Clone()
	e3_mat2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e3_mat2)

	-- 封锁超量素材
	local e3_mat3=e3_mat1:Clone()
	e3_mat3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e3_mat3)

	-- 封锁连接素材
	local e3_mat4=e3_mat1:Clone()
	e3_mat4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e3_mat4)

	-- ④：超量素材全部被取除的场合强制发动：对方场上所有卡破坏，给予最高原本攻击力一半的伤害 (HOPT: id)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DETACH_MATERIAL)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

-- ==================== ① 效果：去除素材代替破坏 ====================
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp)
			and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then -- 96: 是否代替破坏？
		return true
	else
		return false
	end
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end

-- ==================== ② 效果：受到的效果伤害变为0 ====================
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT~=0 then return 0 end
	return val
end

-- ==================== ③ 效果：「No.」素材压制与大类素材封锁 ====================
function s.numcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_NUMBER)
end

function s.atktg(e,c)
	return c:IsAttackPos()
end

-- ==================== ④ 效果：素材归零全场破坏 + 斩杀伤害 ====================
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetOverlayCount()==0
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsType,nil,TYPE_MONSTER)
		if #og>0 then
			-- 检索破坏的怪兽中最高的原本攻击力
			local max_atk=0
			for tc in aux.Next(og) do
				local text_atk=tc:GetTextAttack()
				if text_atk>max_atk then
					max_atk=text_atk
				end
			end
			if max_atk>0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,math.floor(max_atk/2),REASON_EFFECT)
			end
		end
	end
end